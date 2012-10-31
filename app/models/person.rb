# A Person
#
# Normally an owner or otherwise responsbile for an audit function.
class Person < ActiveRecord::Base
  include AuthoredModel
  include AuthorizedModel
  include RelatedModel

  attr_accessible :email, :name, :company, :language

  has_many :object_people, :dependent => :destroy

  belongs_to :language, :class_name => 'Option', :conditions => { :role => 'person_language' } 

  is_versioned_ext

  validates :email, :presence => true

  @valid_relationships = []

  def custom_edges
    # Returns a list of additional edges that aren't returned by the default method.
    edges = Set.new
    object_people.each do |op|
      edges.add(Edge.new(self, op.personable, "person_#{op.role}_for_#{op.personable.class.to_s.underscore}"))
    end

    edges
  end

  def display_name
    email
  end

  def self.db_search(q)
    q = "%#{q}%"
    t = arel_table
    where(t[:name].matches(q).
      or(t[:email].matches(q)))
  end

  def abilities(object = nil)
    Authorization::abilities(self, object)
  end
end
