class ControlDocumentDescriptor
  include DataMapper::Resource
  include AuthoredModel

  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :control, :key => true
  belongs_to :evidence_descriptor, 'DocumentDescriptor', :key => true

  is_versioned_ext :on => [:updated_at]
end
