# System to CO many to many relationship
# `state` is the rolled up state from the System to Control association
class SystemSection < ActiveRecord::Base
  include AuthoredModel
  include StateModel

  attr_accessible :section, :system

  belongs_to :section
  belongs_to :system

  is_versioned_ext
end
