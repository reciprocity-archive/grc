class OrgGroup < ActiveRecord::Base
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
    { :to   => Location, :via => :org_group_has_province_over_location },
    { :to   => Market,   :via => :org_group_has_province_over_market },
    { :to   => Product,  :via => :org_group_has_province_over_product },
    { :both => OrgGroup, :via => :org_group_is_affiliated_with_org_group },
    { :to   => Location, :via => :org_group_is_dependent_on_location },
    { :from => Program,  :via => :program_is_relevant_to_org_group },
    { :to   => System,   :via => :org_group_has_process },
    { :to   => RiskyAttribute, :via => :org_group_has_risky_attribute },
  ]

  def display_name
    slug
  end
end
