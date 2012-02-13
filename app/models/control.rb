require 'slugged_model'

# A control
#
# Hierarchically, a Control has one or more Control Objectives
# as parents and those must all be of the same Regulation.
#
# The slug of a Control has to have the slug of the regulation as prefix.
class Control
  include DataMapper::Resource
  include DataMapper::Validate
  include SluggedModel
  extend SluggedModel::ClassMethods

  before :save, :upcase_slug

  FREQUENCIES = [:day, :week, :month, :quarter, :year]

  property :id, Serial
  property :title, String, :required => true, :length => 255
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

  # Business area classification
  belongs_to :business_area, :required => false

  # The regulation this control is under, for ease of validation of slug
  # and COs.
  belongs_to :regulation, :required => false

  # Many to many with BizProcess
  has n, :biz_process_controls
  has n, :biz_processes, :through => :biz_process_control, :order => :slug

  # Many to many with System
  has n, :system_controls
  has n, :systems, :through => :system_controls

  # The types of evidence (Documents) that may be attached to this control
  # during an audit.
  has n, :evidence_descriptors, 'DocumentDescriptor', :through => Resource

  # The result of an audit test
  belongs_to :test_result, :required =>  false

  # Which controls are implemented by this one.  A company
  # control may implement several regulation controls.
  has n, :implemented_controls, "Control", :through => Resource, :order => :slug

  # Many to many with Control Objective
  has n, :control_objectives, :through => Resource, :order => :slug

  property :created_at, DateTime
  property :updated_at, DateTime

  # All non-company regulation controls
  def self.all_non_company
    all(:regulation => { :company => false }, :order => :slug)
  end

  # All company controls
  def self.all_company
    all(:regulation => { :company => true }, :order => :slug)
  end

  # All controls that may be attached to a CO (regulation
  # must match)
  def self.for_control_objective(co)
    all(:regulation => co.regulation, :order => :slug)
  end

  # All controls that may be attached to a system (must be
  # company control)
  def self.for_system(s)
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

  # IDs of related Biz Processes (used by many2many widget)
  def biz_process_ids
    biz_processes.map { |bp| bp.id }
  end

  # IDs of related Control Objectives (used by many2many widget)
  def control_objective_ids
    control_objectives.map { |co| co.id }
  end

  # IDs of related Control Objectives (used by many2many widget)
  def co_ids
    control_objectives.map { |co| co.id }
  end

  # IDs of related Controls (used by many2many widget)
  def implemented_control_ids
    implemented_controls.map { |c| c.id }
  end

  # IDs of related evidence descriptors (used by many2many widget)
  def evidence_descriptor_ids
    evidence_descriptors.map { |e| e.id }
  end
end
