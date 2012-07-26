class ObjectPerson < ActiveRecord::Base
  belongs_to :person
  belongs_to :personable, :polymorphic => true

  def as_json_with_role_and_person
    as_json(:only => :role, :include => :person)
  end
end
