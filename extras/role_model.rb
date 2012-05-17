module RoleModel
  ROLES = [:tech, :business]

  def role
    index = read_attribute(:role) || self.class.columns_hash['role'].default
    ROLES[index]
  end

  def role=(value)
    write_attribute(:role, ROLES.index(value))
  end

  def self.included(model)
    model.validates :role, :presence => true
  end
end
