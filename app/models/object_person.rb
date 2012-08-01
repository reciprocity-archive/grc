class ObjectPerson < ActiveRecord::Base
  belongs_to :person
  belongs_to :personable, :polymorphic => true

  validates :role, :presence => true

  def as_json_with_role_and_person(options={})
    as_json(options.merge(:only => :role, :include => :person))
  end
end
