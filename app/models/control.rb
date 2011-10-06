require 'slugged_model'

class Control
  include DataMapper::Resource
  include DataMapper::Validate
  include SluggedModel
  extend SluggedModel::ClassMethods

  before :save, :upcase_slug

  FREQUENCIES = [:day, :week, :month, :quarter, :year]

  property :id, Serial
  property :title, String, :required => true
  property :slug, String, :required => true

  validates_with_block :slug do
    validate_slug
  end

  property :is_key, Boolean, :required => true, :default => false
  property :description, Text
  property :frequency, Integer
  property :frequency_type, Enum[*FREQUENCIES], :default => :day
  property :fraud_related, Boolean, :required => true, :default => false
  property :assertion, String
  property :effective_at, DateTime

  belongs_to :business_area, :required => false
  belongs_to :regulation, :required => false
  has n, :biz_process_controls
  has n, :biz_processes, :through => :biz_process_control
  has n, :system_controls
  has n, :systems, :through => :system_controls
  has n, :evidence_descriptors, 'DocumentDescriptor', :through => Resource
  belongs_to :test_result, :required =>  false
  has n, :implemented_controls, "Control", :through => Resource
  has n, :control_objectives, :through => Resource

  property :created_at, DateTime
  property :updated_at, DateTime

  def self.all_non_company
    all(:regulation => { :company => false })
  end

  def self.all_company
    all(:regulation => { :company => true })
  end

  def self.for_control_objective(co)
    all(:regulation => co.regulation)
  end

  def self.for_system(co)
    all_company
  end

  def parent
    regulation
  end

  def display_name
    "#{slug} - #{title}"
  end

  def system_ids
    systems.map { |s| s.id }
  end

  def biz_process_ids
    biz_processes.map { |bp| bp.id }
  end

  def control_objective_ids
    control_objectives.map { |co| co.id }
  end

  def co_ids
    control_objectives.map { |co| co.id }
  end

  def implemented_control_ids
    implemented_controls.map { |c| c.id }
  end

  def evidence_descriptor_ids
    evidence_descriptors.map { |e| e.id }
  end
end
