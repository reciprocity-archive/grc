class BizProcessSection < ActiveRecord::Base
  include AuthoredModel

  belongs_to :biz_process
  belongs_to :section

  is_versioned_ext
end
