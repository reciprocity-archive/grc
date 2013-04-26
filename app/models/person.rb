# A Person
#
# Normally an owner or otherwise responsbile for an audit function.
class Person < ActiveRecord::Base
  include AuthoredModel
  include AuthorizedModel
  include RelatedModel

  attr_accessible :email, :name, :company, :language

  has_one :account

  has_many :object_people, :dependent => :destroy

  belongs_to :language, :class_name => 'Option', :conditions => { :role => 'person_language' } 

  is_versioned_ext

  validates :email, :presence => true, :email => true, :uniqueness => true

  def custom_edges
    # Returns a list of additional edges that aren't returned by the default method.
    edges = Set.new
    object_people.each do |op|
      edges.add(Edge.new(self, op.personable, "person_#{op.role}_for_#{op.personable_type.to_s.underscore}"))
    end

    edges
  end

  def self.custom_all_edges
    # Returns a list of additional edges that aren't returned by the default method.
    edges = Set.new

    includes(:object_people).each do |p|
      p.object_people.each do |op|
        edges.add(Edge.new(p, op.personable, "person_#{op.role}_for_#{op.personable_type.to_s.underscore}"))
      end
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

  def for_email
    if name.present? && email.present?
      "#{name} <#{email}>"
    elsif name.present?
      name
    else
      email
    end
  end
  
  def last_name
    if !name.nil?
      name.split(' ').last
    end
  end
end
