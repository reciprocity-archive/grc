class BizProcessPerson < ActiveRecord::Base
  include AuthoredModel
  include RoleModel

  belongs_to :person
  belongs_to :biz_process

  is_versioned_ext
end
