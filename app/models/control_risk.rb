# Control to Risk many to many
class ControlRisk < ActiveRecord::Base
  include CommonModel

  attr_accessible :control, :risk

  belongs_to :control
  belongs_to :risk

  is_versioned_ext

  #def self.by_control_risk(risk_id, control_id, cycle)
  #  sc = ControlRisk
  #    .where(:risk_id => risk_id,
  #           :control_id => control_id)
  #    .first
  #end
end
