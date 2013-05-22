class PopulationSample < ActiveRecord::Base
  include CommonModel

  attr_accessible :response, :population_document, :population, :sample_worksheet_document, :samples, :sample_evidence_document

  belongs_to :response

  belongs_to :population_document, :class_name => "Document"
  belongs_to :sample_worksheet_document, :class_name => "Document"
  belongs_to :sample_evidence_document, :class_name => "Document"

  is_versioned_ext

  validates_presence_of :response
  validates :population, :samples, :numericality => true, :allow_blank => true

  def display_name
    "#{response.system.title} population sample"
  end

  def as_json(options={})
    super(options.merge :include => [
      { :population_document => { :methods => :link_url}},
      { :sample_worksheet_document => { :methods => :link_url}}, 
      { :sample_evidence_document => { :methods => :link_url}}
    ])
  end

end
