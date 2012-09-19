require 'slugged_model'

# A company / regulation control
#
class Control < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include FrequentModel
  include SearchableModel
  include AuthorizedModel

  CATEGORY_TYPE_ID = 100

  attr_accessible :title, :slug, :description, :program, :effective_at, :frequency, :frequency_type, :section_ids, :type, :kind, :means, :categories

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

  validates :slug, :title, :program,
    :presence => { :message => "needs a value" }
  validates :slug,
    :uniqueness => { :message => "must be unique" }

  validate :slug do
    validate_slug
  end

  before_save :upcase_slug

  def display_name
    "#{slug} - #{title}"
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
