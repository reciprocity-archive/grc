# System to CO many to many relationship
# `state` is the rolled up state from the System to Control association
class SystemSection < ActiveRecord::Base
  include AuthoredModel

  after_initialize do
    self.state = :green if self.state.nil?
  end

  validates :state, :presence => true

  belongs_to :section
  belongs_to :system

  is_versioned_ext

  def state
    ControlState::VALUES[read_attribute(:state)]
  end

  def state=(value)
    write_attribute(:state, ControlState::VALUES.index(value))
  end
end
