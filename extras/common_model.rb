module CommonModel
  def self.included(model)
    model.send(:include, AuthoredModel)
    model.has_many :object_people, :as => :personable, :dependent => :destroy
    model.has_many :people, :through => :object_people
    model.has_many :object_documents, :as => :documentable, :dependent => :destroy
    model.has_many :documents, :through => :object_documents
  end
end
