class OrgGroup < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel

  attr_accessible :title, :slug, :description, :url, :version, :start_date, :stop_date

  has_many :object_people, :as => :personable, :dependent => :destroy
  has_many :people, :through => :object_people

  is_versioned_ext

  validates :title,
    :presence => { :message => "needs a value" }

  @valid_relationships = [
    { :relationship_type =>:org_group_has_province_over_location,
      :related_model => Location,
      :related_model_endpoint => :destination},
    { :relationship_type => :org_group_has_province_over_market,
      :related_model => Market,
      :related_model_endpoint => :destination},
    { :relationship_type =>:org_group_has_province_over_product,
      :related_model => Product,
      :related_model_endpoint => :destination},
    { :relationship_type => :org_group_is_affiliated_with_org_group,
      :related_model => OrgGroup,
      :related_model_endpoint => :both},
    { :relationship_type => :org_group_is_dependent_on_location,
      :related_model => Location,
      :related_model_endpoint => :destination},
    { :relationship_type => :program_is_relevant_to_org_group,
      :related_model => Program,
      :related_model_endpoint => :source}
  ]

  def display_name
    slug
  end

  def authorizing_objects
    # FIXME
    Set.new([self])
  end
end