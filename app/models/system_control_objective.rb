# System to CO many to many relationship
class SystemControlObjective
  include DataMapper::Resource

  property :id, Serial

  # This is the rolled up state from the System to Control association
  property :state, Enum[*ControlState::VALUES], :default => :green, :required => true

  belongs_to :control_objective
  belongs_to :system

  property :created_at, DateTime
  property :updated_at, DateTime

  is_versioned :on => [:updated_at]
end
