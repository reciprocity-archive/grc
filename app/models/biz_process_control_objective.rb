class BizProcessControlObjective < ActiveRecord::Base
  include AuthoredModel

  belongs_to :biz_process
  belongs_to :control_objective

  is_versioned_ext
end
