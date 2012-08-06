class SystemPerson < ActiveRecord::Base
  include AuthoredModel
  include RoleModel

  attr_accessible :person, :system

  belongs_to :person
  belongs_to :system

  is_versioned_ext
end
