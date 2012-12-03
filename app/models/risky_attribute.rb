class RiskyAttribute < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel

  attr_accessible :title, :slug, :description, :url, :version, :type, :start_date, :stop_date

  has_many :object_people, :as => :personable, :dependent => :destroy
  has_many :people, :through => :object_people

  has_many :object_documents, :as => :documentable, :dependent => :destroy
  has_many :documents, :through => :object_documents

  belongs_to :type, :class_name => 'Option', :conditions => { :role => 'product_type' }

  is_versioned_ext

  validates :title,
    :presence => { :message => "needs a value" }

  @valid_relationships = [
    { :relationship_type => :risky_attribute_is_an_attribute_of_org_group,
      :related_model => OrgGroup,
      :related_model_endpoint => :source },
    { :relationship_type => :risky_attribute_is_an_attribute_of_product,
      :related_model => Product,
      :related_model_endpoint => :source },
    { :relationship_type => :risky_attribute_is_an_attribute_of_location,
      :related_model => Location,
      :related_model_endpoint => :source },
    #{ :relationship_type => :risky_attribute_is_an_attribute_of_project,
    #  :related_model => Project,
    #  :related_model_endpoint => :source },
    { :relationship_type => :risky_attribute_is_an_attribute_of_market,
      :related_model => Market,
      :related_model_endpoint => :source },
    #{ :relationship_type => :risky_attribute_is_an_attribute_of_data_asset,
    #  :related_model => DataAsset,
    #  :related_model_endpoint => :source },
  ]

  def display_name
    slug
  end

end
