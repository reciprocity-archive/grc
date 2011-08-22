class Regulation
  include DataMapper::Resource
  include SluggedModel
  extend SluggedModel::ClassMethods

  before :save, :upcase_slug

  property :id, Serial
  property :title, String, :required => true
  property :slug, String, :required => true
  property :description, Text
  property :company, Boolean, :default => false, :required => true

  has n, :control_objectives

  belongs_to :source_document, 'Document', :required => false
  belongs_to :source_website, 'Document', :required => false
  
  def display_name
    slug
  end

  property :created_at, DateTime
  property :updated_at, DateTime
end
