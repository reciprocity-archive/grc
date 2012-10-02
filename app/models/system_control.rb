# System to Control many to many
class SystemControl < ActiveRecord::Base
  include CommonModel
  include StateModel

  attr_accessible :control, :system, :cycle

  belongs_to :control
  belongs_to :system
  belongs_to :cycle

  is_versioned_ext

  def self.by_system_control(system_id, control_id, cycle)
    sc = SystemControl
      .where(:system_id => system_id,
             :control_id => control_id,
             :cycle_id => cycle)
      .first
  end
end
