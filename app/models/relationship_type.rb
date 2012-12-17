class RelationshipType < ActiveRecord::Base
  include AuthoredModel
  include SanitizableAttributes

  # attr_accessible :title, :body
  self.primary_key = 'relationship_type'

  has_many :relationships

  is_versioned_ext

  sanitize_attributes :description
end
