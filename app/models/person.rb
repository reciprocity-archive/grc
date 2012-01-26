# A Person
#
# Normally an owner or otherwise responsbile for an audit function.
class Person
  include DataMapper::Resource
  include AuthoredModel

  property :id, Serial
  property :username, String, :required => true
  property :name, String

  property :created_at, DateTime
  property :updated_at, DateTime

  is_versioned_ext :on => [:updated_at]
  
  def display_name
    username
  end
end
