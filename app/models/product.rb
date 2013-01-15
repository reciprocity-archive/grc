class Product < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel
  include SanitizableAttributes

  attr_accessible :title, :slug, :description, :url, :version, :type, :start_date, :stop_date

  has_many :object_people, :as => :personable, :dependent => :destroy
  has_many :people, :through => :object_people

  has_many :object_documents, :as => :documentable, :dependent => :destroy
  has_many :documents, :through => :object_documents

  belongs_to :type, :class_name => 'Option', :conditions => { :role => 'product_type' }

  is_versioned_ext

  sanitize_attributes :description

  validates :title,
    :presence => { :message => "needs a value" }

  #
  # Various relationship-related helpers
  #

  @valid_relationships = [
    { :from => OrgGroup, :via => :org_group_has_province_over_product },
    { :both => Product,  :via => :product_is_affiliated_with_product },
    { :to   => Location, :via => :product_is_dependent_on_location },
    { :to   => Product,  :via => :product_is_dependent_on_product },
    { :from => Product,  :via => :product_is_dependent_on_product },
    { :to   => Market,   :via => :product_is_sold_into_market },
    { :from => Program,  :via => :program_is_relevant_to_product },
    { :to   => System,   :via => :product_has_process },
    { :to   => RiskyAttribute, :via => :product_has_risky_attribute },
  ]

  def display_name
    slug
  end

  def systems
    Relationship.where(
      :source_type => 'Product', :source_id => id,
      :destination_type => 'System',
      :relationship_type_id => 'product_has_process'
    ).includes(:destination).map(&:destination)
  end

  def dependent_products
    Relationship.where(
      :source_type => 'Product', :source_id => id,
      :destination_type => 'Product',
      :relationship_type_id => 'product_is_dependent_on_product'
    ).includes(:destination).map(&:destination)
  end
end
