# A Regulatory Program
#
# The top of the Program -> CO -> Control hierarchy
class Program < ActiveRecord::Base
  include CommonModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel

  attr_accessible :title, :slug, :company, :description, :start_date, :stop_date, :audit_start_date, :audit_frequency, :audit_duration, :organization, :url, :scope, :kind, :version

  has_many :sections, :order => :slug, :dependent => :destroy
  has_many :controls, :order => :slug, :dependent => :destroy

  has_many :cycles, :dependent => :destroy

  belongs_to :type, :class_name => 'Option', :conditions => { :role => 'program_type' }
  belongs_to :kind, :class_name => 'Option', :conditions => { :role => 'program_kind' }

  belongs_to :audit_frequency, :class_name => 'Option', :conditions => { :role => 'audit_frequency' }
  belongs_to :audit_duration, :class_name => 'Option', :conditions => { :role => 'audit_duration' }

  is_versioned_ext

  before_save :assign_company_boolean_from_program_kind

  validates :title,
    :presence => { :message => "needs a value" }

  #
  # Various relationship-related helpers
  #

  @valid_relationships = [
    { :relationship_type =>:program_is_relevant_to_location,
      :related_model => Location,
      :related_model_endpoint => :destination},
    { :relationship_type => :program_is_relevant_to_org_group,
      :related_model => OrgGroup,
      :related_model_endpoint => :destination},
    { :relationship_type => :program_is_relevant_to_product,
      :related_model => Product,
      :related_model_endpoint => :destination}
  ]

  def custom_edges
    # Returns a list of additional edges that aren't returned by the default method.
    edges = Set.new
    sections.each do |section|
      edges.add(Edge.new(self, section, :program_includes_section))
    end

    controls.each do |control|
      edges.add(Edge.new(self, control, :program_includes_control))
    end
    edges
  end

  def self.custom_all_edges
    # Returns a list of additional edges that aren't returned by the default method.
    edges = Set.new
    includes(:sections, :controls).each do |p|
      p.sections.each do |section|
        edges.add(Edge.new(p, section, :program_includes_section))
      end

      p.controls.each do |control|
        edges.add(Edge.new(p, control, :program_includes_control))
      end
    end
    edges
  end

  def display_name
    slug
  end

  def assign_company_boolean_from_program_kind
    if !changed_attributes.include?('company')
      self.company = !(self.kind && self.kind.title == 'Regulation')
    end
    true
  end
end
