class Location < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel

  attr_accessible :title, :slug, :description, :url, :version, :start_date, :stop_date

  has_many :object_people, :as => :personable, :dependent => :destroy
  has_many :people, :through => :object_people

  has_many :object_documents, :as => :documentable, :dependent => :destroy
  has_many :documents, :through => :object_documents

  is_versioned_ext

  validates :title,
    :presence => { :message => "needs a value" }

  @valid_relationships = [
    { :relationship_type => :location_is_dependent_on_location,
      :related_model => Location,
      :related_model_endpoint => :both},
    { :relationship_type => :market_is_dependent_on_location,
      :related_model => Market,
      :related_model_endpoint => :source},
     { :relationship_type => :org_group_has_province_over_location,
      :related_model => OrgGroup,
      :related_model_endpoint => :source},
    { :relationship_type => :org_group_is_dependent_on_location,
      :related_model => OrgGroup,
      :related_model_endpoint => :source},
    { :relationship_type =>:program_is_relevant_to_location,
      :related_model => Program,
      :related_model_endpoint => :source}
  ]

  def display_name
    slug
  end
end
