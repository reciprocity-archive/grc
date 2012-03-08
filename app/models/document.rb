# A Document
#
# Can either be linked by a URL or attached from Google Docs.
#
# Evidence is associated with a Document Descriptor
class Document
  include DataMapper::Resource
  VALID_SCHEMES = ['http', 'https']

  validates_with_block :link do
    if VALID_SCHEMES.include?(link.scheme)
      true
    else
      [false, "Scheme must be one of #{VALID_SCHEMES.join(',')}"]
    end
  end

  property :id, Serial
  property :title, String, :length => 256
  property :link, URI, :length => 1024, :unique_index => true

  belongs_to :document_descriptor, :required => false

  property :reviewed, Boolean, :default => false, :required => true
  property :good, Boolean, :default => true, :required => false

  def display_name
    title
  end

  property :created_at, DateTime
  property :updated_at, DateTime

  def complete?
    !link.nil? && !link.to_s.blank?
  end
end
