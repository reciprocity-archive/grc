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
    { :both => Location, :via => :location_is_dependent_on_location },
    { :from => Market,   :via => :market_is_dependent_on_location },
    { :from => OrgGroup, :via => :org_group_has_province_over_location },
    { :from => OrgGroup, :via => :org_group_is_dependent_on_location },
    { :from => Program,  :via => :program_is_relevant_to_location }
  ]

  def display_name
    slug
  end
end
