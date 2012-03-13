# A business process involves multiple systems and is controlled by multiple controls
# and control objectives.
class BizProcess
  include DataMapper::Resource
  include AuthoredModel
  include SluggedModel
  extend SluggedModel::ClassMethods

  before :save, :upcase_slug

  property :id, Serial
  property :title, String, :required => true, :length => 255
  property :slug, String, :required => true
  property :description, Text

  has n, :systems, :through => :biz_process_systems, :order => :slug
  has n, :biz_process_systems
  has n, :control_objectives, :through => :biz_process_control_objectives, :order => :slug
  has n, :biz_process_control_objectives
  has n, :controls, :through => :biz_process_controls, :order => :slug
  has n, :biz_process_controls

  # Responsible party
  belongs_to :owner, 'Person', :required => false

  # Other parties
  has n, :biz_process_persons
  has n, :persons, :through => :biz_process_persons

  has n, :policies, 'Document', :through => :biz_process_documents 
  has n, :biz_process_documents
  # TODO(miron) business units

  property :created_at, DateTime
  property :updated_at, DateTime

  is_versioned_ext :on => [:updated_at]

  # All biz processes that could be attached to a system
  def self.for_system(s)
    all
  end

  # Return ids of related COs (used by many2many widget)
  def co_ids
    control_objectives.map { |co| co.id }
  end

  # Return ids of related Controls (used by many2many widget)
  def control_ids
    controls.map { |c| c.id }
  end

  # Return ids of related Systems (used by many2many widget)
  def system_ids
    systems.map { |s| s.id }
  end

  def display_name
    "#{slug} - #{title}"
  end
end
