class Risk < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel
  include SanitizableAttributes
  include DatedModel

  RATINGS = {
    1 => "Minimal",
    2 => "Moderate",
    3 => "Significant",
    4 => "Major",
    5 => "Extreme"
  }

  attr_accessible :title, :slug, :description, :url, :version, :type, :start_date, :stop_date, :likelihood, :likelihood_rating, :threat_vector, :trigger, :preconditions, :impact, :financial_impact_rating, :reputational_impact_rating, :operational_impact_rating, :inherent_risk, :risk_mitigation, :residual_risk

  has_many :object_people, :as => :personable, :dependent => :destroy
  has_many :people, :through => :object_people

  has_many :object_documents, :as => :documentable, :dependent => :destroy
  has_many :documents, :through => :object_documents

  # Many to many with RiskyAttribute
  has_many :risk_risky_attributes, :dependent => :destroy
  has_many :risky_attributes, :through => :risk_risky_attributes

  # Many to many with Control
  has_many :control_risks, :dependent => :destroy
  has_many :controls, :through => :control_risks

  # Categories
  has_many :categorizations, :as => :categorizable, :dependent => :destroy
  has_many :categories, :through => :categorizations, :conditions => { :scope_id => Control::CATEGORY_TYPE_ID }

  is_versioned_ext

  sanitize_attributes :description

  validates :title,
    :presence => { :message => "needs a value" }

  def display_name
    slug
  end

  def related_objects_with_risky_attributes
    objects = {}
    risky_attributes.each do |ra|
      ra.attributed_objects.each do |object|
        objects[object] ||= []
        objects[object].push(ra)
      end
    end
    related_objects.each do |object|
      objects[object] ||= []
    end
    objects
  end

  def related_objects
    Relationship.where(
      :source_type => self.class.name,
      :source_id => id,
    ).includes(:destination).map(&:destination)
  end

  def controls_display
    controls.uniq.map(&:slug).join(",")
  end

  def categories_display
    categories.uniq.map(&:name).join(",")
  end
  
  def max_impact
    likelihood_rating * inherent_risk.to_i
  end
  
  def likelihood_rating
    read_attribute(:likelihood_rating).to_f / 5
  end
  
  def adjusted_likelihood
    (likelihood_rating * 5).to_i
  end
end
