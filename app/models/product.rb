# Product
#
class Product < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel

  attr_accessible :title, :slug, :description, :url, :version, :type

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
  def add_within_scope_of(program)
    Relationship.create(:source => program, :destination => self, :relationship_type_id => 'within_scope_of')
  end

  def within_scope_of_programs
    Program.relevant_to(self)
  end

  def within_scope_of
    within_scope_of_programs
  end

  def self.within_scope_of(program)
    related_to_source(program, 'within_scope_of')
  end


  def display_name
    slug
  end

  def authorizing_objects
    # FIXME
    Set.new([self])
  end
end
