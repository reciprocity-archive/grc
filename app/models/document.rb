# A Document
#
# Can either be linked by a URL or attached from Google Docs.
#
# Evidence is associated with a Document Descriptor
class Document < ActiveRecord::Base
  include AuthoredModel
  VALID_SCHEMES = ['http', 'https']

  validate :link do
    if link.nil? or VALID_SCHEMES.include?(link.scheme)
      true
    else
      errors.add(:link, "Scheme must be one of #{VALID_SCHEMES.join(', ')}")
    end
  end

  belongs_to :document_descriptor

  validates :link,     :uniqueness => true

  def display_name
    title
  end

  def link
    read_attribute(:link) && URI(read_attribute(:link))
  end

  is_versioned_ext

  def complete?
    !link.nil? && !link.to_s.blank?
  end
end
