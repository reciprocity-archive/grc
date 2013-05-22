class Product < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel
  include SanitizableAttributes
  include BusinessObjectModel
  include DatedModel

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

  def display_name
    slug
  end

end
