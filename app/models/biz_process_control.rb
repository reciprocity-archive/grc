class BizProcessControl
  include DataMapper::Resource

  property :id, Serial
  property :state, Enum[*ControlState::VALUES], :default => :green, :required => true
  property :ticket, String

  belongs_to :control
  belongs_to :biz_process

  property :created_at, DateTime
  property :updated_at, DateTime
end
