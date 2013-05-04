class ObjectPerson < ActiveRecord::Base
  include AuthoredModel
  include AuthorizedModel
  include RelatedModel
  include DatedModel

  attr_accessible :person, :personable, :notes, :start_date, :stop_date

  belongs_to :person
  belongs_to :personable, :polymorphic => true

  is_versioned_ext

  validates :role, :presence => true

  def as_json_with_role_and_person(options={})
    as_json(options.merge(:only => :role, :include => :person))
  end
end
