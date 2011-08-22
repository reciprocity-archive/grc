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
