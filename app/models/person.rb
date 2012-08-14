# A Person
#
# Normally an owner or otherwise responsbile for an audit function.
class Person < ActiveRecord::Base
  include AuthoredModel

  attr_accessible :email, :name, :company, :language

  validates :email, :presence => true

  has_many :object_people, :dependent => :destroy

  belongs_to :language, :class_name => 'Option', :conditions => { :role => 'person_language' } 

  is_versioned_ext

  def display_name
    email
  end

  def self.search(q)
    q = "%#{q}%"
    t = arel_table
    where(t[:name].matches(q).
      or(t[:email].matches(q)))
  end

  def abilities(object = nil)
    Authorization::abilities(self, object)
  end

  def allowed?(ability, object = nil, &block)
    Authorization::allowed?(ability, self, object, &block)
  end
end
