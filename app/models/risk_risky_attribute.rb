# Risk to RiskyAttribute many to many
class RiskRiskyAttribute < ActiveRecord::Base
  include CommonModel

  attr_accessible :risk, :risky_attribute

  belongs_to :risk
  belongs_to :risky_attribute

  is_versioned_ext

  #def self.by_system_control(system_id, control_id, cycle)
  #  sc = SystemControl
  #    .where(:system_id => system_id,
  #           :control_id => control_id,
  #           :cycle_id => cycle)
  #    .first
  #end
end
