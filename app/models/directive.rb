# A Regulation, Policy, or Contract

class Directive < ActiveRecord::Base
  include CommonModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel
  include SanitizableAttributes
  include DatedModel

  KINDS = [
    "Regulation",
    "Company Controls Policy",
    "Company Policy",
    "Org Group Policy",
    "Data Asset Policy",
    "Product Policy",
    "Contract-Related Policy",
    "Company Library",
    "Fed Contract Library",
    "Contract",
  ]

  META_KINDS = {
    :regulation => [ "Regulation" ],
    :library    => [ "Company Library", "Fed Contract Library" ],
    :policy     => [ "Company Policy", "Org Group Policy", "Data Asset Policy", "Product Policy", "Contract-Related Policy", "Company Controls Policy" ],
    :contract   => [ "Contract" ],
  }

  attr_accessible :title, :slug, :company, :description, :start_date, :stop_date, :audit_start_date, :audit_frequency, :audit_duration, :organization, :url, :scope, :kind, :version

  has_many :sections, :order => :slug, :dependent => :destroy
  has_many :controls, :order => :slug, :dependent => :destroy

  has_many :program_directives, :dependent => :destroy
  has_many :programs, :through => :program_directives

  belongs_to :audit_frequency, :class_name => 'Option', :conditions => { :role => 'audit_frequency' }
  belongs_to :audit_duration, :class_name => 'Option', :conditions => { :role => 'audit_duration' }

  is_versioned_ext

  sanitize_attributes :description

  before_save :assign_company_boolean_from_directive_kind

  validates :title,
    :presence => { :message => "needs a value" }

  def self.without_stealth_directives
    joins(:program_directives => :programs).
    where(:programs => { :kind => "Directive" })
  end

  def is_stealth_directive?
    company_controls? && programs.count == 1 && programs.first.company_controls?
  end

  def company_controls?
    kind == "Company Controls Policy"
  end

  def contract?
    Directive.meta_kind_for(kind) == :contract
  end

  def meta_kind
    Directive.meta_kind_for(kind)
  end

  def self.meta_kind_for(kind)
    Directive::META_KINDS.each do |meta_kind, kinds|
      return meta_kind if kinds.include?(kind.to_s)
    end
    nil
  end

  def self.kinds_for(meta_kind)
    meta_kind = meta_kind.to_sym if meta_kind.kind_of?(String)
    return Directive::KINDS unless meta_kind.present?
    return Directive::META_KINDS[meta_kind.to_sym] || []
  end

  def section_meta_kind
    case self.meta_kind
    when :contract
      :clause
    when :company_controls
      :company_controls
    else
      :section
    end
  end

  def default_slug_prefix
    (meta_kind || :directive).to_s.upcase
  end

  def self.all_company_controls_first
    directives = self.all
    directives =
      directives.select {|p| p.company_controls?} +
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
      self.company = !([:regulation, :contract].include?(self.meta_kind))
    end
    true
  end
end
