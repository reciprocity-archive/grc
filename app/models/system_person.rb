class SystemPerson < ActiveRecord::Base
  include AuthoredModel
  include RoleModel

  belongs_to :person
  belongs_to :system

  is_versioned_ext
end
