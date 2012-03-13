module AuthoredModel
  # Typecast form parameters into the right primitive to work around a DataMapper dirty-detection bug.
  #
  # If we don't do this, the persistence layer thinks all non-strings params are modifications
  # where in fact we might just have changed false => 0, which is a no-op.  This is important
  # for versioning so we don't create no-change versions when nothing was changed.
  def authored_update(author, params)
    tparams = {}
    trels = {}
    params.each do |key, value|
      property = model.properties[key]
      if property && property.respond_to?(:typecast)
        # typecast scalar properties
        value = property.typecast(value)
        tparams[key] = value
      elsif key.to_s.ends_with?('_ids')
        # handle association changes
        base_key = key.to_s.sub(/_ids$/, '').pluralize
        relation = model.relationships[base_key]
        raise "missing association #{base_key}" unless relation

        existing = relation.get(self)
        existing_ids = existing.map {|e| e.id}
        new_ids = value - existing_ids
        destroy_ids = existing_ids - value

        if relation.is_a? DataMapper::Associations::ManyToMany::Relationship
          through = relation.through
          rel_objs = through.get(self)
          rel_objs.each do |rel_obj|
            if destroy_ids.include?(through.child_key.get(rel_obj).first)
              rel_obj.modified_by = author
              rel_obj.save
            end
          end
        elsif relation.is_a? DataMapper::Associations::OneToMany::Relationship
          rel_objs = relation.get(self)
          rel_objs.each do |rel_obj|
            if destroy_ids.include?(relation.child_key.get(rel_obj).id)
              rel_obj.modified_by = author
              rel_obj.save
            end
          end
        else
          raise "can only handle one2many or many2many relations" 
        end
        tparams[relation.field] = value.map { |id| relation.child_model.get(id) } 
        trels[relation] = new_ids
        #relation.set(self, value.map { |id| relation.child_model.get(id) })
      else
        tparams[key] = value
      end
    end
    return false unless update(tparams.merge(:modified_by_id => author.id))

    trels.each do |relation, new_ids|
      if relation.is_a? DataMapper::Associations::ManyToMany::Relationship
        through = relation.through
        rel_objs = through.get(self)
        rel_objs.each do |rel_obj|
          if new_ids.include?(through.child_key.get(rel_obj).first)
            rel_obj.modified_by = author
            rel_obj.save
          end
        end
      elsif relation.is_a? DataMapper::Associations::OneToMany::Relationship
        rel_objs = relation.get(self)
        rel_objs.each do |rel_obj|
          if new_ids.include?(relation.child_key.get(rel_obj).id)
            rel_obj.modified_by = author
            rel_obj.save
          end
        end
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
    def is_versioned_ext(opts)
      is_versioned(opts)
      belongs_to :modified_by, 'Account', :required => false
    end
  end
end
