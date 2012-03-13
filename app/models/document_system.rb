class DocumentSystem
  include DataMapper::Resource
  include AuthoredModel

  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :document, :key => true
  belongs_to :system, :key => true

  is_versioned_ext :on => [:updated_at]
end
