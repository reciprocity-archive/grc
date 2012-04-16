require 'slugged_model'

# A control
#
# Hierarchically, a Control has one or more Control Objectives
# as parents and those must all be of the same Regulation.
#
# The slug of a Control has to have the slug of the regulation as prefix.
class Control < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel

  after_initialize do
    self.is_key = false if self.is_key.nil?
    self.frequency_type ||= :day
    self.fraud_related = false if self.fraud_related.nil?
    self.technical = true if self.technical.nil?
  end

  before_save :upcase_slug

  FREQUENCIES = [:day, :week, :month, :quarter, :year]

  validates :slug, :title, :presence => true

  validate :slug do
    validate_slug
  end

  # Business area classification
  belongs_to :business_area

  # The regulation this control is under, for ease of validation of slug
  # and COs.
  belongs_to :regulation

  # Many to many with BizProcess
  has_many :biz_process_controls
  has_many :biz_processes, :through => :biz_process_controls, :order => :slug

  # Many to many with System
  has_many :system_controls
  has_many :systems, :through => :system_controls

  # The types of evidence (Documents) that may be attached to this control
  # during an audit.
  has_many :evidence_descriptors, :class_name => 'DocumentDescriptor', :through => :control_document_descriptors
  has_many :control_document_descriptors

  # The result of an audit test
  belongs_to :test_result

  # Which controls are implemented by this one.  A company
  # control may implement several regulation controls.
  has_many :implemented_controls, :class_name => "Control", :through => :control_controls, :order => :slug
  has_many :control_controls

  # Many to many with Control Objective
  has_many :control_objectives, :through => :control_control_objectives, :order => :slug
  has_many :control_control_objectives

  is_versioned_ext

  def frequency_type
    FREQUENCIES[read_attribute(:frequency_type)]
  end

  def frequency_type=(value)
    write_attribute(:frequency_type, FREQUENCIES.index(value))
  end

  # All non-company regulation controls
  def self.all_non_company
    joins(:regulation).
      where(:regulations => { :company => false }).
      order(:slug)
  end

  # All company controls
  #scope :all_company,
  #  joins(:regulation).
  #  where(:regulations => { :company => true }).
  #  order(:slug)
  def self.all_company
    joins(:regulation).
      where(:regulations => { :company => true }).
      order(:slug)
  end

  # All controls that may be attached to a CO (regulation
  # must match)
  def self.for_control_objective(co)
    where(:regulation_id => co.regulation.id).order(:slug)
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

  class ControlCycle
    def initialize(scs)
      @scs = scs
    end

    def system_ids
      @scs.map &:system_id
    end

    def self.model_name
      ControlCycle
    end
    def self.param_key
      :control
    end
  end

  def system_controls_for_cycle(cycle)
    scs = system_controls
    scs = scs.where(:cycle_id => cycle.id) if cycle
    ControlCycle.new(scs)
  end
end
