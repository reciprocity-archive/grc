class Project < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel
  include SanitizableAttributes
  include BusinessObjectModel

  attr_accessible :title, :slug, :description, :url, :version, :start_date, :stop_date

  has_many :object_people, :as => :personable, :dependent => :destroy
  has_many :people, :through => :object_people

  has_many :object_documents, :as => :documentable, :dependent => :destroy
  has_many :documents, :through => :object_documents

  is_versioned_ext

  sanitize_attributes :description

  validates :title,
    :presence => { :message => "needs a value" }

  @valid_relationships = [
    { :to   => Project,   :via => :project_contains_a_project },
    { :from => Project,   :via => :project_contains_a_project },
    { :to   => Facility, :via => :project_is_dependent_on_facility },
    { :from => OrgGroup, :via => :org_group_has_province_over_project },
    { :from => Product,  :via => :product_is_sold_into_project },
    { :to   => RiskyAttribute, :via => :project_has_risky_attribute },
  ]

  def display_name
    slug
  end
end
