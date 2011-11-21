# A Person
#
# Normally an owner or otherwise responsbile for an audit function.
class Person
  include DataMapper::Resource

  property :id, Serial
  property :username, String, :required => true
  property :name, String

  property :created_at, DateTime
  property :updated_at, DateTime
  
  def display_name
    username
  end
end
