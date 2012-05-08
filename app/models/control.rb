require 'slugged_model'

# A company control
#
class Control < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include FrequentModel

  before_save :upcase_slug

  validates :slug, :title, :presence => true

  validate :slug do
    validate_slug
  end

  belongs_to :program

  belongs_to :parent, :class_name => 'Control'

  # Business area classification
  belongs_to :business_area

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

  # Which sections are implemented by this one.  A company
  # control may implement several sections.
  has_many :sections, :through => :control_sections, :order => :slug
  has_many :control_sections

  has_many :implemented_controls, :through => :control_controls, :order => :slug
  has_many :control_controls

  is_versioned_ext

  # All non-company section controls
  def self.all_non_company
    joins(:section).
      where(:sections => { :company => false }).
      order(:slug)
  end

  # All controls that may be attached to a system (must be
  # company control)
  def self.for_system(s)
    all
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

  # IDs of related Sections (used by many2many widget)
  def implemented_section_ids
    sections.map { |c| c.id }
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
