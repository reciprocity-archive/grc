module RoleModel
  ROLES = [:tech, :business]

  def role
    ROLES[read_attribute(:role) || 0]
  end

  def role=(value)
    write_attribute(:role, ROLES.index(value))
  end

  def self.included(model)
    model.validates :role, :presence => true
  end
end
