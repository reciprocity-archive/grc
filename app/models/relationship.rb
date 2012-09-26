class Relationship < ActiveRecord::Base
  include AuthoredModel

  # Note: No accessible attributes - you pretty much
  # never want to allow changes to these without authorization.

  belongs_to :source, :polymorphic => true
  belongs_to :destination, :polymorphic => true
  belongs_to :relationship_type

  scope :manages, where(:relationship_type_id => 'manager_of')
end
