class DocumentSystem < ActiveRecord::Base
  include AuthoredModel

  belongs_to :document
  belongs_to :system

  is_versioned_ext
end
