class Risk < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel
  include SanitizableAttributes

  RATINGS = {
    1 => "Minimal",
    2 => "Moderate",
    3 => "Significant",
    4 => "Major",
    5 => "Extreme"
  }

  attr_accessible :title, :slug, :description, :url, :version, :type, :start_date, :stop_date, :likelihood, :likelihood_rating, :threat_vector, :trigger, :preconditions, :financial_impact, :financial_impact_rating, :reputational_impact, :reputational_impact_rating, :operational_impact, :operational_impact_rating

  has_many :object_people, :as => :personable, :dependent => :destroy
  has_many :people, :through => :object_people

  has_many :object_documents, :as => :documentable, :dependent => :destroy
  has_many :documents, :through => :object_documents

  is_versioned_ext

  sanitize_attributes :description

  validates :title,
    :presence => { :message => "needs a value" }

  def display_name
    slug
  end

end
