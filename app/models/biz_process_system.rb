class BizProcessSystem < ActiveRecord::Base
  include AuthoredModel

  belongs_to :biz_process
  belongs_to :system

  is_versioned_ext
end
