class ObjectDocument < ActiveRecord::Base
  belongs_to :document
  belongs_to :documentable, :polymorphic => true

  def as_json_with_role_and_document(options={})
    as_json(options.merge(:only => :role, :include => { :document => { :methods => :link_url }}))
  end
end
