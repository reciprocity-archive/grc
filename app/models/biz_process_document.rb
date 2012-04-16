class BizProcessDocument < ActiveRecord::Base
  include AuthoredModel

  belongs_to :biz_process
  belongs_to :policy, :class_name => 'Document'

  is_versioned_ext
end
