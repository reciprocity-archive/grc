class SystemPerson < ActiveRecord::Base
  include AuthoredModel

  after_initialize do
    self.role = :tech if self.role.nil?
  end

  validates :role, :presence => true

  ROLES = [:tech, :business]
  def role
    ROLES[read_attribute(:role)]
  end

  def role=(value)
    write_attribute(:role, ROLES.index(value))
  end

  belongs_to :person
  belongs_to :system

  is_versioned_ext
end
