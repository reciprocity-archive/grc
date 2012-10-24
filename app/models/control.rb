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

  attr_accessible :title, :slug, :description, :program, :section_ids, :type, :kind, :means, :categories, :verify_frequency, :url, :start_date, :stop_date, :version, :documentation_description

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
  has_many :control_sections

  has_many :implemented_controls, :through => :control_controls
  has_many :control_controls

  has_many :implementing_controls, :through => :implementing_control_controls, :source => :control
  has_many :implementing_control_controls, :class_name => "ControlControl", :foreign_key => "implemented_control_id"

  belongs_to :type, :class_name => 'Option', :conditions => { :role => 'control_type' }
  belongs_to :kind, :class_name => 'Option', :conditions => { :role => 'control_kind' }
  belongs_to :means, :class_name => 'Option', :conditions => { :role => 'control_means' }
  belongs_to :verify_frequency, :class_name => 'Option', :conditions => { :role => 'verify_frequency' }

  is_versioned_ext

  validates :title, :program,
    :presence => { :message => "needs a value" }

  validate :slug do
    validate_slug_parent
  end

  def display_name
    "#{slug} - #{title}"
  end

  def custom_edges
    # Returns a list of additional edges that aren't returned by the default method.

    edges = []
    if parent
      edge = {
        :source => parent,
        :destination => self,
        :type => :control_includes_control
      }
      edges.push(edge)
    end

    if program
      edge = {
        :source => program,
        :destination => self,
        :type => :program_includes_control
      }
      edges.push(edge)
    end

    systems.each do |system|
      edge = {
        :source => self,
        :destination => system,
        :type => :control_implemented_by_system
      }
      edges.push(edge)
    end

    sections.each do |section|
      edge = {
        :source => section,
        :destination => self,
        :type => :section_implemented_by_control
      }
      edges.push(edge)
    end

    implemented_controls.each do |control|
      edge = {
        :source => control,
        :destination => self,
        :type => :control_implemented_by_control
      }
      edges.push(edge)
    end

    implementing_controls.each do |control|
      edge = {
        :source => self,
        :destination => control,
        :type => :control_implemented_by_control
      }
      edges.push(edge)
    end

    edges
  end

  # Return all objects that allow operations on this object
  def authorizing_objects
    aos = Set.new
    aos.add(self)
    aos.add(program)

    implementing_controls.each do |control|
      aos.merge(control.authorizing_objects)
    end

    sections.each do |section|
      aos.merge(section.authorizing_objects)
    end
    aos
  end

  def self.category_tree
    Category.roots.all.map { |c| [c, c.children.all] }
  end
end
