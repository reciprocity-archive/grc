module AuthoredModel
  # Typecast form parameters into the right primitive to work around a DataMapper dirty-detection bug.
  #
  # If we don't do this, the persistence layer thinks all non-strings params are modifications
  # where in fact we might just have changed false => 0, which is a no-op.  This is important
  # for versioning so we don't create no-change versions when nothing was changed.
  def authored_update(author, params, mass_assign = true)
    if (!params)
      # Early out if there are no changes. Makes testing easier.
      return true
    end
    tparams = {}
    trels = {}
    params.each do |key, value|
      property = self.class.columns_hash[key.to_s.singularize.to_sym]
      if property && property.respond_to?(:typecast)
        # typecast scalar properties
        value = property.typecast(value)
        tparams[key] = value
      elsif key.to_s.ends_with?('_ids')
        # handle association changes
        base_key = key.to_s.sub(/_ids$/, '').pluralize

        relation = association(base_key.to_sym)
        existing = send(base_key).all
        existing_ids = existing.map {|e| e.id}
        new_ids = value - existing_ids
        destroy_ids = existing_ids - value

        if relation.is_a? ActiveRecord::Associations::HasManyThroughAssociation
          through = association(relation.through_reflection.name)
          rel_objs = self.send(relation.through_reflection.name).all
          rel_objs.each do |rel_obj|
            if destroy_ids.include?(rel_obj.id)
              rel_obj.modified_by = author
              rel_obj.save
            end
          end
        # Removed as unused and not ported to ActiveRecord
        #elsif relation.is_a? ActiveRecord::Associations::HasManyAssociation
        #  rel_objs = relation.get(self)
        #  rel_objs.each do |rel_obj|
        #    if destroy_ids.include?(relation.child_key.get(rel_obj).id)
        #      rel_obj.modified_by = author
        #      rel_obj.save
        #    end
        #  end
        else
          raise "can only handle one2many or many2many relations"
        end
        tparams[base_key] = value.map { |id| relation.klass.find(id) }
        trels[relation] = new_ids
      else
        tparams[key] = value
      end
    end
    self.modified_by = author

    if mass_assign
      self.assign_attributes(tparams)
    else
      tparams.each do |key, value|
        send(key + '=', value)
      end
    end

    return false unless save

    trels.each do |relation, new_ids|
      if relation.is_a? ActiveRecord::Associations::HasManyThroughAssociation
        through = association(relation.through_reflection.name)
        rel_objs = self.send(relation.through_reflection.name).all
        rel_objs.each do |rel_obj|
          if new_ids.include?(rel_obj.id)
            rel_obj.modified_by = author
            rel_obj.save
          end
        end
      # Removed as unused and not ported to ActiveRecord
      #elsif relation.is_a? DataMapper::Associations::OneToMany::Relationship
      #  raise "OneToMany"
      #  rel_objs = relation.get(self)
      #  rel_objs.each do |rel_obj|
      #    if new_ids.include?(relation.child_key.get(rel_obj).id)
      #      rel_obj.modified_by = author
      #      rel_obj.save
      #    end
      #  end
      else
        raise "can only handle many2many relations"
      end
    end

    return true
  end

  def authored_destroy(author)
    self.modified_by = author
    destroy
  end

  def self.included(model)
    model.extend(ClassMethods)
  end

  module ClassMethods
    def is_versioned_ext(opts=nil)
      belongs_to :modified_by, :class_name => 'Account'
      has_paper_trail :on => [:update, :destroy]
    end
  end
end
