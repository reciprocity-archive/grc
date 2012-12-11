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
    { :from => OrgGroup,  :via => :risky_attribute_is_an_attribute_of_org_group },
    { :from => Product,   :via => :risky_attribute_is_an_attribute_of_product },
    { :from => Location,   :via => :risky_attribute_is_an_attribute_of_location },
    #{ :from => Project,   :via => :risky_attribute_is_an_attribute_of_project },
    { :from => Market,   :via => :risky_attribute_is_an_attribute_of_market },
    #{ :from => DataAsset, :via => :risky_attribute_is_an_attribute_of_data_asset },
  ]

  def display_name
    slug
  end

end
