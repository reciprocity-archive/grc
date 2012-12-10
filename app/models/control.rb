require 'slugged_model'

# A company / regulation control
#
class Control < ActiveRecord::Base
  include CommonModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel

  CATEGORY_TYPE_ID = 100
  CATEGORY_ASSERTION_TYPE_ID = 102

  attr_accessible :title, :slug, :description, :program, :section_ids, :type, :kind, :means, :categories, :verify_frequency, :url, :start_date, :stop_date, :version, :documentation_description

  def general_categories
    categories.ctype(CATEGORY_TYPE_ID)
  end

  def assertion_categories
    categories.ctype(CATEGORY_ASSERTION_TYPE_ID)
  end

  define_index do
    indexes :slug, :sortable => true
    indexes :title
    indexes :description
    has :created_at, :updated_at, :program_id
  end

  belongs_to :program

  belongs_to :parent, :class_name => 'Control'

  # Many to many with System
  has_many :system_controls, :dependent => :destroy
  has_many :systems, :through => :system_controls

  # Which sections are implemented by this one.  A company
  # control may implement several sections.
  has_many :sections, :through => :control_sections
  has_many :control_sections, :dependent => :destroy

  has_many :implemented_controls, :through => :control_controls
  has_many :control_controls, :dependent => :destroy

  has_many :implementing_controls, :through => :implementing_control_controls, :source => :control
  has_many :implementing_control_controls, :class_name => "ControlControl", :foreign_key => "implemented_control_id", :dependent => :destroy

  belongs_to :type, :class_name => 'Option', :conditions => { :role => 'control_type' }
  belongs_to :kind, :class_name => 'Option', :conditions => { :role => 'control_kind' }
  belongs_to :means, :class_name => 'Option', :conditions => { :role => 'control_means' }
  belongs_to :verify_frequency, :class_name => 'Option', :conditions => { :role => 'verify_frequency' }

  is_versioned_ext

  validates :title, :program, :program_id,
    :presence => { :message => "needs a value" }

  validate :slug do
    validate_slug_parent
  end

  def display_name
    "#{slug} - #{title}"
  end

  def custom_edges
    # Returns a list of additional edges that aren't returned by the default method.

    edges = Set.new
    if parent
      edges.add(Edge.new(parent, self, :control_includes_control))
    end

    if program
      edges.add(Edge.new(program, self, :program_includes_control))
    end

    systems.each do |system|
      edges.add(Edge.new(self, system, :control_implemented_by_system))
    end

    sections.each do |section|
      edges.add(Edge.new(section, self, :section_implemented_by_control))
    end

    implemented_controls.each do |control|
      edges.add(Edge.new(control, self, :control_implemented_by_control))
    end

    implementing_controls.each do |control|
      edges.add(Edge.new(self, control, :control_implemented_by_control))
    end

    edges
  end

  def self.custom_all_edges
    # Returns a list of additional edges that aren't returned by the default method.
    edges = Set.new
    includes(:parent, :program, :systems, :sections, :implemented_controls, :implementing_controls).each do |c|
      if c.parent
        edges.add(Edge.new(c.parent, c, :control_includes_control))
      end

      if c.program
        edges.add(Edge.new(c.program, c, :program_includes_control))
      end

      c.systems.each do |system|
        edges.add(Edge.new(c, system, :control_implemented_by_system))
      end

      c.sections.each do |section|
        edges.add(Edge.new(section, c, :section_implemented_by_control))
      end

      c.implemented_controls.each do |control|
        edges.add(Edge.new(control, c, :control_implemented_by_control))
      end

      c.implementing_controls.each do |control|
        edges.add(Edge.new(c, control, :control_implemented_by_control))
      end
    end

    edges
  end

  def systems_display
    systems.map {|x| x.slug}.join(',')
  end

  def categories_display
    categories.ctype(CATEGORY_TYPE_ID).map {|x| x.slug}.join(',')
  end

  def assertions_display
    categories.ctype(CATEGORY_ASSERTION_TYPE_ID).map {|x| x.slug}.join(',')
  end

  def references_display
    documents.map do |d|
      "#{d.description} [#{d.link} #{d.title}]"
    end.join("\n")
  end

  def operator_display
    p = object_people.detect {|x| x.role == 'owner'}
    p ? p.person.email : ''
  end

  def self.category_tree
    Category.roots.all.map { |c| [c, c.children.all] }
  end
end
