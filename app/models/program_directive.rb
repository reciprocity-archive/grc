# Program to Directive many to many
class ProgramDirective < ActiveRecord::Base
  include CommonModel

  attr_accessible :program, :directive

  belongs_to :program
  belongs_to :directive

  is_versioned_ext

  #def self.by_system_control(system_id, control_id, cycle)
  #  sc = SystemControl
  #    .where(:system_id => system_id,
  #           :control_id => control_id,
  #           :cycle_id => cycle)
  #    .first
  #end
end
