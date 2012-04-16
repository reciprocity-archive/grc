class BizProcessPerson < ActiveRecord::Base
  include AuthoredModel

  ROLES = [:tech, :business]

  after_initialize do
    self.role = :tech if self.role.nil?
  end

  validates :role, :presence => true

  belongs_to :person
  belongs_to :biz_process

  is_versioned_ext

  def role
    ROLES[read_attribute(:role)]
  end

  def role=(value)
    write_attribute(:role, ROLES.index(value))
  end
end
