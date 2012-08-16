# A Person
#
# Normally an owner or otherwise responsbile for an audit function.
class Person < ActiveRecord::Base
  include AuthoredModel

  attr_accessible :username, :name, :company, :language

  validates :username, :presence => true

  has_many :object_people, :dependent => :destroy

  belongs_to :language, :class_name => 'Option', :conditions => { :role => 'person_language' } 

  is_versioned_ext

  def display_name
    username
  end

  def self.search(q)
    q = "%#{q}%"
    t = arel_table
    where(t[:name].matches(q).
      or(t[:username].matches(q)))
  end
end
