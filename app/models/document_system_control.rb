class DocumentSystemControl
  include DataMapper::Resource
  include AuthoredModel

  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :evidence, 'Document', :key => true
  belongs_to :system_control, :key => true

  is_versioned_ext :on => [:updated_at]
end
