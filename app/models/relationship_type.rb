class RelationshipType < ActiveRecord::Base
  # attr_accessible :title, :body
  self.primary_key = 'relationship_type'

  has_many :relationships
end
