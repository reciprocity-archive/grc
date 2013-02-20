# A Regulation, Policy, or Contract

class Directive < ActiveRecord::Base
  include CommonModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel
  include SanitizableAttributes

  attr_accessible :title, :slug, :company, :description, :start_date, :stop_date, :audit_start_date, :audit_frequency, :audit_duration, :organization, :url, :scope, :kind, :version

  has_many :sections, :order => :slug, :dependent => :destroy
  has_many :controls, :order => :slug, :dependent => :destroy

  has_many :program_directives, :dependent => :destroy
  has_many :programs, :through => :program_directives

  has_many :cycles, :dependent => :destroy

  belongs_to :kind, :class_name => 'Option', :conditions => { :role => 'directive_kind' }

  belongs_to :audit_frequency, :class_name => 'Option', :conditions => { :role => 'audit_frequency' }
  belongs_to :audit_duration, :class_name => 'Option', :conditions => { :role => 'audit_duration' }

  is_versioned_ext

  sanitize_attributes :description

  before_save :assign_company_boolean_from_directive_kind

  validates :title,
    :presence => { :message => "needs a value" }

  def company_controls?
    self.kind && self.kind.title == 'Company Controls'
  end

  def contract?
    self.kind && self.kind.title == 'Contract'
  end

  def self.all_company_controls_first
    directives = self.includes(:kind)
    directives = directives.select {|p| p.company_controls?} +
      directives.reject {|p| p.company_controls?}
  end

  def custom_edges
    # Returns a list of additional edges that aren't returned by the default method.
    edges = Set.new
    sections.each do |section|
      edges.add(Edge.new(self, section, :directive_includes_section))
    end

    controls.each do |control|
      edges.add(Edge.new(self, control, :directive_includes_control))
    end
    edges
  end

  def self.custom_all_edges
    # Returns a list of additional edges that aren't returned by the default method.
    edges = Set.new
    includes(:sections, :controls).each do |p|
      p.sections.each do |section|
        edges.add(Edge.new(p, section, :directive_includes_section))
      end

      p.controls.each do |control|
        edges.add(Edge.new(p, control, :directive_includes_control))
      end
    end
    edges
  end

  def display_name
    slug
  end

  def assign_company_boolean_from_directive_kind
    if !changed_attributes.include?('company')
      self.company = !(self.kind && self.kind.title == 'Regulation')
    end
    true
  end
end
