# A regulation
#
# The top of the Regulation -> CO -> Control hierarchy
class Regulation < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel

  before_save :upcase_slug

  after_initialize do
    self.company = false if self.company.nil?
  end

  validates :title, :slug, :presence => true

  has_many :control_objectives, :order => :slug

  belongs_to :source_document, :class_name => 'Document'
  belongs_to :source_website, :class_name => 'Document'
  
  def display_name
    slug
  end

  is_versioned_ext
end
