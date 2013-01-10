class Response < ActiveRecord::Base
  include AuthoredModel
  include AuthorizedModel

  attr_accessible :request, :system, :status, :population, :samples,
    :population_document, :sample_worksheet_document, :sample_evidence_document

  belongs_to :request
  belongs_to :system

  has_one :population_sample
  has_many :meetings

  has_many :object_people, :as => :personable, :dependent => :destroy
  has_many :people, :through => :object_people

  has_many :object_documents, :as => :documentable, :dependent => :destroy
  has_many :documents, :through => :object_documents

  is_versioned_ext

  validates :request, :system,
    :presence => { :message => "needs a value" }

  def display_name
    "#{request.pbc_control_code} - #{system.title}"
  end

  def as_json_with_system(options={})
    as_json(options.merge(:include => { :system => { :include => [:people, { :documents => { :methods => :link_url }} , :object_people, :object_documents] } , :object_people => { :include => :person } , :people => {} }))
  end
end
