module AuthoredModel
  # Typecast form parameters into the right primitive to work around a DataMapper dirty-detection bug.
  #
  # If we don't do this, the persistence layer thinks all non-strings params are modifications
  # where in fact we might just have changed false => 0, which is a no-op.  This is important
  # for versioning so we don't create no-change versions when nothing was changed.
  def authored_update(author, params)
    tparams = {}
    params.each do |key, value|
      property = model.properties[key.to_sym]
      if property && property.respond_to?(:typecast)
        value = property.typecast(value)
      end
      tparams[key] = value
    end
    update(tparams.merge(:modified_by_id => author.id))
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
