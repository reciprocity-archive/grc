module GrcModel
  def self.included(model)
    model.send(:include, AuthoredModel)
    model.has_many :categorizations, :as => :categorizable, :dependent => :destroy
    model.has_many :object_persons, :as => :personable, :dependent => :destroy
    model.has_many :object_documents, :as => :documentable, :dependent => :destroy
  end
end
