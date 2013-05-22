class Option < ActiveRecord::Base
  include AuthoredModel
  include SanitizableAttributes

  attr_accessible :role, :title, :description, :required

  def to_s
    title
  end

  scope :options_for, lambda { |role| where(:role => role) }
  scope :ordered_by_title_desc, order("#{table_name}.title DESC")

  is_versioned_ext

  sanitize_attributes :description

  def display_name
    title
  end

  def self.db_search(q)
    q = "%#{q}%"
    t = arel_table
    where(t[:role].matches(q))
  end

  ROLES = [
    "asset_type",
    "audit_duration",
    "audit_frequency",
    # "control_type",
    "control_kind",
    "control_means",
    "document_status",
    "document_type",
    "document_year",
    "entity_kind",
    "entity_type",
    "language",
    "facility_kind",
    "facility_type",
    "network_zone",
    "person_language",
    "product_kind",
    "product_type",
    #"directive_kind",
    "reference_type",
    "request_type",
    # "system_type",
    "system_kind",
    "threat_type",
    "verify_frequency"
  ]
  
  ROLES_OVERRIDE = {
    "verify_frequency" => "frequency"
  }
  
  def self.human_name(role)
    return (ROLES_OVERRIDE.has_key?(role) ? ROLES_OVERRIDE[role] : role).humanize.titleize
  end
  
  def self.options_with_none_for(role)
    options = self.options_for(role)
    options.unshift(Option.new(:title => "None"))
  end
end
