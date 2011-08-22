class SystemControlObjective
  include DataMapper::Resource

  property :id, Serial
  property :state, Enum[*ControlState::VALUES], :default => :green, :required => true

  belongs_to :control_objective
  belongs_to :system

  property :created_at, DateTime
  property :updated_at, DateTime
end
