# Many to many relationship between BizProcess and Control
#
# Some additional attributes are attached, including the state of the control
# and a ticket (if state is not green).  Since a control can apply to multiple processes,
# these attributes cannot be attached to it directly.
class BizProcessControl
  include DataMapper::Resource

  property :id, Serial
  property :state, Enum[*ControlState::VALUES], :default => :green, :required => true
  property :ticket, String

  belongs_to :control
  belongs_to :biz_process

  property :created_at, DateTime
  property :updated_at, DateTime

  is_versioned :on => [:updated_at]
end
