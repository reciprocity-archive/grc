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

  has_many :sections, :order => :slug
  has_many :controls, :order => :slug

  has_many :cycles

  belongs_to :type, :class_name => 'Option', :conditions => { :role => 'program_type' }
  belongs_to :kind, :class_name => 'Option', :conditions => { :role => 'program_kind' }

  belongs_to :audit_frequency, :class_name => 'Option', :conditions => { :role => 'audit_frequency' }
  belongs_to :audit_duration, :class_name => 'Option', :conditions => { :role => 'audit_duration' }

  is_versioned_ext

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

  def display_name
    slug
  end

  def authorizing_objects
    Set.new([self])
  end
end
