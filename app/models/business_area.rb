# A business area (used to classify Controls)
class BusinessArea
  include DataMapper::Resource

  property :id, Serial
  property :title, String, :length => 256

  def display_name
    title
  end

  property :created_at, DateTime
  property :updated_at, DateTime

  is_versioned :on => [:updated_at]
end
