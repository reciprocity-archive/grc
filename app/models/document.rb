# A Document
#
# Can either be linked by a URL or attached from Google Docs.
class Document < ActiveRecord::Base
  include AuthoredModel
  include AuthorizedModel
  include RelatedModel
  include SanitizableAttributes

  VALID_SCHEMES = ['http', 'https', 'file']

  attr_accessible :link, :title, :description, :type, :kind, :language, :year

  has_many :object_documents, :dependent => :destroy
  has_many :population_worksheets_documented, :class_name => "PopulationSample", :dependent => :nullify, :foreign_key => "population_document_id"
  has_many :sample_worksheets_documented, :class_name => "PopulationSample", :dependent => :nullify, :foreign_key => "sample_worksheet_document_id"
  has_many :sample_evidences_documented, :class_name => "PopulationSample", :dependent => :nullify, :foreign_key => "sample_evidence_document_id"

  belongs_to :type, :class_name => 'Option', :conditions => { :role => 'document_type' }
  belongs_to :kind, :class_name => 'Option', :conditions => { :role => 'reference_type' }
  belongs_to :year, :class_name => 'Option', :conditions => { :role => 'document_year' }
  belongs_to :language, :class_name => 'Option', :conditions => { :role => 'language' }

  is_versioned_ext

  sanitize_attributes :description

  validate :link do
    begin
      if link.nil? || VALID_SCHEMES.include?(link.scheme)
        true
      else
        errors.add(:link, "scheme must be one of #{VALID_SCHEMES.join(', ')}")
      end
    rescue
      errors.add(:link, "must be a valid URI")
    end
  end

  validates :link,
    :presence => { :message => "needs a value" },
    :uniqueness => true

  def display_name
    title
  end

  def link
    link = read_attribute(:link)
    URI(link) if !link.blank?
  rescue
    link
  end

  def self.linkify(value)
    if !value.blank?
      if !VALID_SCHEMES.include?(value.split(':')[0])
        value = "http://#{value}"
      else
        value
      end
    end
  end

  def link=(value)
    if !value.blank? && !VALID_SCHEMES.include?(value.split(':')[0])
      value = "http://#{value}"
    end
    write_attribute(:link, value)
  end

  def link_url
    link && link.to_s
  end

  def document_type
    type && type.title
  end

  def complete?
    !link.nil? && !link.to_s.blank?
  end
  
  def count_population_samples
    t = PopulationSample.arel_table
    is_population_document = t[:population_document_id].eq(id)
    is_sample_worksheet_document = t[:sample_worksheet_document_id].eq(id)
    is_sample_evidence_document = t[:sample_evidence_document_id].eq(id)
    PopulationSample.where(
      is_population_document.or(is_sample_worksheet_document).or(is_sample_evidence_document)
    ).count
  end

  def self.db_search(q)
    q = "%#{q}%"
    t = arel_table
    where(t[:title].matches(q).
      or(t[:link].matches(q)))
  end
end
