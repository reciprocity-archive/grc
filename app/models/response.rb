class Response < ActiveRecord::Base
  include AuthoredModel
  include AuthorizedModel

  attr_accessible :request, :system, :status, :population, :samples,
    :population_document, :sample_worksheet_document, :sample_evidence_document

  belongs_to :request
  belongs_to :system

  has_one :population_sample, :dependent => :destroy
  after_create :create_population_sample_if_type
  has_many :meetings

  has_many :object_people, :as => :personable, :dependent => :destroy
  has_many :people, :through => :object_people

  has_many :object_documents, :as => :documentable, :dependent => :destroy
  has_many :documents, :through => :object_documents

  is_versioned_ext

  validates :request,
    :presence => { :message => "needs a value" }

  def display_name
    "Response using \"#{system.nil? ? 'no system' : system.title}\""
  end

  def create_population_sample_if_type
    self.create_population_sample if self.request.type_name == 'Population Sample'
  end

  def as_json_with_system(options={})
    if system.nil? then
      o = options.merge(:include => {
        :object_people => { :include => :person }, 
        :people => {}, 
        :population_sample => { 
          :include => { 
            :population_document => { :methods => :link_url }, 
            :sample_worksheet_document => { :methods => :link_url }, 
            :sample_evidence_document => { :methods => :link_url }
          } 
        }, 
        :meetings => {}, 
        :object_documents => {
          :include => { :document => { :methods => :link_url }}
        }, 
        :documents => {
          :methods => :link_url
        }
      }, :methods => :system)
    else
      o = options.merge(:include => { 
        :object_people => { :include => :person }, 
        :people => {}, 
        :population_sample => { 
          :include => { 
            :population_document => { :methods => :link_url }, 
            :sample_worksheet_document => { :methods => :link_url }, 
            :sample_evidence_document => { :methods => :link_url }
          } 
        }, 
        :meetings => {}, 
        :object_documents => {
          :include => { :document => { :methods => :link_url }}
        }, 
        :documents => {
          :methods => :link_url
        },
        :system => { 
          :include => [
            :people, 
            { 
              :documents => { :methods => :link_url }
            }, 
            :object_people, 
            :object_documents
          ] 
        }
      })
    end
    as_json(o)
  end
end
