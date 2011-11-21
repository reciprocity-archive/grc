# Describes a type of Document.
#
# Mainly use to classify types of evidence so that they can be
# organized when attached to Controls
class DocumentDescriptor
  include DataMapper::Resource

  property :id, Serial

  property :title, String, :length => 256
  property :description, Text

  def display_name
    title
  end

  property :created_at, DateTime
  property :updated_at, DateTime
end
