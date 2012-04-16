# Many to many relationship between BizProcess and Control
#
# Some additional attributes are attached, including the state of the control
# and a ticket (if state is not green).  Since a control can apply to multiple processes,
# these attributes cannot be attached to it directly.
class BizProcessControl < ActiveRecord::Base
  include AuthoredModel

  after_initialize do
    self.state = :green if self.state.nil?
  end

  validates :state, :presence => true

  belongs_to :control
  belongs_to :biz_process

  is_versioned_ext

  def state
    ControlState::VALUES[read_attribute(:state)]
  end

  def state=(value)
    write_attribute(:state, ControlState::VALUES.index(value))
  end
end
