class ObjectDocument < ActiveRecord::Base
  include AuthoredModel
  include AuthorizedModel
  include RelatedModel
  include DatedModel

  attr_accessible :document, :documentable, :role, :notes, :start_date, :stop_date

  belongs_to :document
  belongs_to :documentable, :polymorphic => true

  is_versioned_ext

  def as_json_with_role_and_document(options={})
    as_json(options.merge(:only => :role, :include => { :document => { :methods => :link_url }}))
  end
end
