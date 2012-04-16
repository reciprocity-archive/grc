# A Person
#
# Normally an owner or otherwise responsbile for an audit function.
class Person < ActiveRecord::Base
  include AuthoredModel

  validates :username, :presence => true

  is_versioned_ext
  
  def display_name
    username
  end
end
