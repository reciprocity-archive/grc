# Sanitize attributes before validation.
#
# Usage in model:
#
# sanitize_attributes :description, :documentation_description
# 
# For now it just allows defaults, mainly harmless formatting tags, see ActionView::Base.sanitized_allowed_tags
# and ActionView::Base.sanitized_allowed_attributes for whole list.
module SanitizableAttributes
  def self.included(model)
    model.extend(ClassMethods)
  end

  def sanitize!
    self.class.sanitizable_attributes.each do |attr_name|
      sanitized_value = ActionController::Base.helpers.sanitize(self.send("#{attr_name}"))
      self.send("#{attr_name}=", sanitized_value)
    end
  end

  module ClassMethods
    def sanitize_attributes(*attr_names)
      cattr_accessor :sanitizable_attributes
      self.sanitizable_attributes = attr_names

      before_validation :sanitize!
    end
  end
end