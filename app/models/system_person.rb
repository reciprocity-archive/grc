class SystemPerson
  include DataMapper::Resource
  include AuthoredModel

  property :id, Serial
  property :role, Enum[:tech, :business], :default => :tech, :required => true

  belongs_to :person, :key => true
  belongs_to :system, :key => true

  property :created_at, DateTime
  property :updated_at, DateTime

  is_versioned_ext :on => [:updated_at]
end
