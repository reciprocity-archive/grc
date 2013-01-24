class RiskyAttribute < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel
  include SanitizableAttributes

  TYPE_STRINGS = %w(Org\ Group Product Facility Market Project Data\ Asset Process System)

  attr_accessible :title, :slug, :description, :url, :version, :type_string, :start_date, :stop_date

  has_many :object_people, :as => :personable, :dependent => :destroy
  has_many :people, :through => :object_people

  has_many :object_documents, :as => :documentable, :dependent => :destroy
  has_many :documents, :through => :object_documents

  # Many to many with Risk
  has_many :risk_risky_attributes, :dependent => :destroy
  has_many :risks, :through => :risk_risky_attributes

  is_versioned_ext

  sanitize_attributes :description

  validates :title,
    :presence => { :message => "needs a value" }

  def self.type_strings
    TYPE_STRINGS
  end

  def display_name
    slug
  end

  def attributed_objects
    Relationship.where(
      :destination_type => self.class.name,
      :destination_id => id,
    ).includes(:source).map(&:source)
  end
end
