class Product < ActiveRecord::Base
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

  #
  # Various relationship-related helpers
  #
  
  @valid_relationships = [
    { :relationship_type => :org_group_has_province_over_product,
      :related_model => OrgGroup,
      :related_model_endpoint => :source},
    { :relationship_type =>:product_is_affiliated_with_product,
      :related_model => Product,
      :related_model_endpoint => :both},
    { :relationship_type =>:product_is_dependent_on_location,
      :related_model => Location,
      :related_model_endpoint => :destination},
    { :relationship_type =>:product_is_dependent_on_product,
      :related_model => Product,
      :related_model_endpoint => :both},
    { :relationship_type =>:product_is_sold_into_market,
      :related_model => Market,
      :related_model_endpoint => :destination},
    { :relationship_type => :program_is_relevant_to_product,
      :related_model => Program,
      :related_model_endpoint => :source}
  ]

  def display_name
    slug
  end
end
