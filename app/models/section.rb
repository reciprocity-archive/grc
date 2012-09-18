require 'slugged_model'

# A control objective (inverse of risk)
#
# The slug of a Section has to have the slug of the parent as prefix.
class Section < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel

  attr_accessible :title, :slug, :description, :program

  before_save :upcase_slug
  before_save :update_parent_id

  validates :title, :slug,
    :presence => { :message => "needs a value" }
  validates :slug,
    :uniqueness => { :message => "must be unique" }

  validate :slug do
    validate_slug
  end

  define_index do
    indexes :slug, :sortable => true
    indexes :title
    indexes :description
    has :created_at, :updated_at, :program_id
  end

  has_many :controls, :through => :control_sections
  has_many :control_sections
  belongs_to :program
  belongs_to :parent, :class_name => "Section"

  scope :with_controls, includes([:parent, {:controls => [:implementing_controls]}])

  def update_parent_id
    self.parent = self.class.find_parent_by_slug(slug) if parent_id.nil?
  end

  def update_child_parent_ids
    ActiveRecord::Base.transaction do
      self.class.find_descendents_by_slug(slug).each do |child|
        child.parent_id = id if child.parent_id == parent_id
        child.save
      end
    end
  end

  # Create the section and assign the correct parent_id
  def self.create_in_tree(params)
    section = self.new(params)
    if section.parent_id.nil?
      section.parent = self.find_parent_by_slug(section.slug)
    end

    ActiveRecord::Base.transaction do
      if section.save
        self.find_descendents_by_slug(section.slug).each do |child|
          child.parent_id = section.id if child.parent_id == section.parent_id
        end
        section
      end
    end
  end

  def self.find_ancestors_by_slug(slug)
    # Find all possible ancestor slugs
    slugs = []
    while slug.size > 0
      slugs.push(slug)
      slug = slugs.last[0, slugs.last.rindex(/\(|\.|-|^/)]
    end

    # Remove initial slug, since it is not its own ancestor
    slugs.shift

    self.where(:slug => slugs).all
  end

  def self.find_parent_by_slug(slug)
    # Return ancestor section with longest slug (deepest section found)
    sections = self.find_ancestors_by_slug(slug)
    sections.max { |section| section.slug.size }
  end

  def self.find_descendents_by_slug(slug)
    prefix_test = Regexp.new("^#{Regexp.escape(slug)}[$.(-]")
    sections = self.where("#{table_name}.slug LIKE ?", "#{slug}%").all
    sections.select { |section| prefix_test.match(section.slug) }
  end

  # All Sections that could be associated with a control (in same program)
  def self.for_control(control)
    where(:program_id => control.program_id).order(:slug)
  end

  # All Sections that could be associated with a system (any company Section)
  def self.for_system(s)
    self
  end

  # Whether this Section is associated with a company "program"
  def company?
    program.company?
  end

  def display_name
    "#{slug} - #{title}"
  end

  # Return ids of related Controls (used by many2many widget)
  def control_ids
    controls.map { |c| c.id }
  end

  # Return ids of related Systems (used by many2many widget)
  def system_ids
    systems.map { |s| s.id }
  end

  def consolidated_controls
    controls.map do |control|
      control.implementing_controls
    end.flatten
  end

  def linked_controls
    controls.map do |control|
      [control] + control.implementing_controls
    end.flatten
  end

  def preloaded_linked_controls
    controls.map do |control|
      [control] + control.implementing_controls.to_a
    end.flatten
  end

  def authorizing_objects
    aos = Set.new
    aos.add(self)
    aos.add(program)

    if (parent)
      aos.merge(parent.authorizing_objects)
    end
    aos
  end

  is_versioned_ext
end
