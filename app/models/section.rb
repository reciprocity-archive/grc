require 'slugged_model'

# A control objective (inverse of risk)
#
# The slug of a Section has to have the slug of the parent as prefix.
class Section < ActiveRecord::Base
  include CommonModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel
  include SanitizableAttributes

  attr_accessible :title, :slug, :description, :directive, :notes, :url, :parent, :na

  define_index do
    indexes :slug, :sortable => true
    indexes :title
    indexes :description
    has :created_at, :updated_at, :directive_id
  end

  has_many :controls, :through => :control_sections
  has_many :control_sections
  belongs_to :directive
  belongs_to :parent, :class_name => "Section"

  is_versioned_ext

  sanitize_attributes :description, :notes

  before_save :upcase_slug
  before_save :update_parent_id

  validate :require_title_or_description

  def require_title_or_description
    if title.blank? && description.blank?
      errors.add(:title, "either title or description is required")
      errors.add(:description, "either title or description is required")
    end
  end

  scope :with_controls, includes([:parent, {:controls => [:implementing_controls]}])

  def custom_edges
    # Returns a list of additional edges that aren't returned by the default method.

    edges = Set.new
    if parent
      edges.add(Edge.new(parent, self, :section_includes_section))
    end

    if directive
      edges.add(Edge.new(directive, self, :directive_includes_section))
    end

    controls.each do |control|
      edges.add(Edge.new(self, control, :section_implemented_by_control))
    end
    edges
  end

  def self.custom_all_edges
    # Returns a list of additional edges that aren't returned by the default method.

    edges = Set.new

    includes(:parent, :directive, :controls).each do |s|
      if s.parent
        edges.add(Edge.new(s.parent, s, :section_includes_section))
      end

      if s.directive
        edges.add(Edge.new(s.directive, s, :directive_includes_section))
      end

      s.controls.each do |control|
        edges.add(Edge.new(s, control, :section_implemented_by_control))
      end
    end

    edges
  end

  def display_name
    "#{slug} - #{title}"
  end

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

  # Whether this Section is associated with a company "directive"
  def company?
    directive.company?
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

  def default_slug_prefix
    self.directive.section_meta_kind.to_s.upcase
  end
end
