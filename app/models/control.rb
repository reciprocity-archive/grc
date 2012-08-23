require 'slugged_model'

# A company control
#
class Control < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include FrequentModel
  include SearchableModel

  attr_accessible :title, :slug, :description, :program, :technical, :assertion, :effective_at, :is_key, :fraud_related, :frequency, :frequency_type, :business_area_id, :section_ids, :type, :kind, :means, :categories

  CATEGORY_TYPE_ID = 100

  before_save :upcase_slug

  validates :slug, :title, :program,
    :presence => { :message => "needs a value" }
  validates :slug,
    :uniqueness => { :message => "must be unique" }

  validate :slug do
    validate_slug
  end

  belongs_to :program

  belongs_to :parent, :class_name => 'Control'

  # Business area classification
  belongs_to :business_area

  # Many to many with BizProcess
  has_many :biz_process_controls
  has_many :biz_processes, :through => :biz_process_controls

  # Many to many with System
  has_many :system_controls, :dependent => :destroy
  has_many :systems, :through => :system_controls

  # The types of evidence (Documents) that may be attached to this control
  # during an audit.
  has_many :evidence_descriptors, :class_name => 'DocumentDescriptor', :through => :control_document_descriptors
  has_many :control_document_descriptors

  # The result of an audit test
  belongs_to :test_result

  # Which sections are implemented by this one.  A company
  # control may implement several sections.
  has_many :sections, :through => :control_sections
  has_many :control_sections

  has_many :implemented_controls, :through => :control_controls
  has_many :control_controls

  has_many :implementing_controls, :through => :implementing_control_controls, :source => :control
  has_many :implementing_control_controls, :class_name => "ControlControl", :foreign_key => "implemented_control_id"

  has_many :object_people, :as => :personable, :dependent => :destroy
  has_many :people, :through => :object_people

  has_many :object_documents, :as => :documentable, :dependent => :destroy
  has_many :documents, :through => :object_documents

  has_many :categorizations, :as => :categorizable, :dependent => :destroy
  has_many :categories, :through => :categorizations

  belongs_to :type, :class_name => 'Option', :conditions => { :role => 'control_type' }
  belongs_to :kind, :class_name => 'Option', :conditions => { :role => 'control_kind' }
  belongs_to :means, :class_name => 'Option', :conditions => { :role => 'control_means' }

  is_versioned_ext

  # All non-company section controls
  def self.all_non_company
    joins(:section).
      where(:sections => { :company => false }).
      order(:slug)
  end

  def self.category_tree
    Category.roots.all.map { |c| [c, c.children.all] }
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

  # Get the list of both immediate and eventual parents
  def ancestor_controls
    implementing_controls.reduce([]) do |ancestors, control|
      ancestors.push(control)

      # Now traverse up the hierarchy
      control_ancestors = control.ancestor_controls
      ancestors.concat(control_ancestors)
      ancestors
    end
  end

  def ancestor_sections
    # Not only need to look for instance's ancestor sections, but
    # also the ancestor sections of all ancestor controls.
    sections.reduce([]) do |ancestors, section|
      ancestors.push(section)

      # Now traverse up the hierarchy
      section_ancestors = section.ancestors
      ancestors.concat(section_ancestors)
    end
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
