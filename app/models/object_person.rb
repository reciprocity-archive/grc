class ObjectPerson < ActiveRecord::Base
  include AuthoredModel

  attr_accessible :person, :personable, :notes

  belongs_to :person
  belongs_to :personable, :polymorphic => true

  validates :role, :presence => true

  is_versioned_ext

  def as_json_with_role_and_person(options={})
    as_json(options.merge(:only => :role, :include => :person))
  end
end
