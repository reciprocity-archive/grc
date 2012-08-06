class BizProcessPerson < ActiveRecord::Base
  include AuthoredModel
  include RoleModel

  attr_accessible :person, :biz_process

  belongs_to :person
  belongs_to :biz_process

  is_versioned_ext
end
