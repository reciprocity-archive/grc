class ControlRegulation < ActiveRecord::Base
  include AuthoredModel

  belongs_to :control
  belongs_to :section

  is_versioned_ext
end
