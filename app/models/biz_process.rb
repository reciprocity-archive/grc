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
  has n, :systems, :through => Resource
  has n, :control_objectives, :through => Resource
  has n, :controls, :through => Resource

  belongs_to :owner, 'Person', :required => false

  has n, :policies, 'Document', :through => Resource 
  # TODO(miron) business units

  property :created_at, DateTime
  property :updated_at, DateTime

  def self.for_system(s)
    all
  end

  def co_ids
    control_objectives.map { |co| co.id }
  end

  def control_ids
    controls.map { |c| c.id }
  end

  def system_ids
    systems.map { |s| s.id }
  end

  def display_name
    "#{slug} - #{title}"
  end
end
