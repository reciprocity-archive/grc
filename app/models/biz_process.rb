# A business process involves multiple systems and is controlled by multiple controls
# and control objectives.
class BizProcess
  include DataMapper::Resource
  include SluggedModel
  extend SluggedModel::ClassMethods

  before :save, :upcase_slug

  property :id, Serial
  property :title, String, :required => true
  property :slug, String, :required => true
  property :description, Text

  has n, :biz_process_controls
  has n, :systems, :through => Resource, :order => :slug
  has n, :control_objectives, :through => Resource, :order => :slug
  has n, :controls, :through => Resource, :order => :slug

  belongs_to :owner, 'Person', :required => false

  has n, :policies, 'Document', :through => Resource 
  # TODO(miron) business units

  property :created_at, DateTime
  property :updated_at, DateTime

  # All biz processes that could be attached to a system
  def self.for_system(s)
    all
  end

  # Return ids of related COs (used by many2many widget)
  def co_ids
    control_objectives.map { |co| co.id }
  end

  # Return ids of related COs (used by many2many widget)
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
