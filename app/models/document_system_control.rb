class DocumentSystemControl < ActiveRecord::Base
  include AuthoredModel

  belongs_to :evidence, :class_name => 'Document'
  belongs_to :system_control

  is_versioned_ext
end
