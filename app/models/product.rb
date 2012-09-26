# Product
#
class Product < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel

  attr_accessible :title, :slug, :description, :url, :version, :type

  has_many :object_people, :as => :personable, :dependent => :destroy
  has_many :people, :through => :object_people

  has_many :object_documents, :as => :documentable, :dependent => :destroy
  has_many :documents, :through => :object_documents

  belongs_to :type, :class_name => 'Option', :conditions => { :role => 'product_type' }

  is_versioned_ext

  validates :title, :slug,
    :presence => { :message => "needs a value" }
  validates :slug,
    :uniqueness => { :message => "must be unique" }

  before_save :upcase_slug

  def display_name
    slug
  end

  def authorizing_objects
    # FIXME
    Set.new([self])
  end
end
