class ObjectDocument < ActiveRecord::Base
  belongs_to :document
  belongs_to :documentable, :polymorphic => true

  def as_json_with_role_and_document
    as_json(:only => :role, :include => :document)
  end
end
