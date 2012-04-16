class ControlDocumentDescriptor < ActiveRecord::Base
  include AuthoredModel

  belongs_to :control
  belongs_to :evidence_descriptor, :class_name => 'DocumentDescriptor'

  is_versioned_ext
end
