# A Regulatory Program
#
# The top of the Program -> CO -> Control hierarchy
class Program < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include FrequentModel
  include SearchableModel
  include AuthorizedModel

  attr_accessible :title, :slug, :company, :description

  has_many :sections, :order => :slug
  has_many :controls, :order => :slug

  has_many :cycles

  has_many :object_people, :as => :personable, :dependent => :destroy
  has_many :people, :through => :object_people

  has_many :object_documents, :as => :documentable, :dependent => :destroy
  has_many :documents, :through => :object_documents

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
    Set.new([self])
  end
end
