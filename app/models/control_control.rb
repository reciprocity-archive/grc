class ControlControl < ActiveRecord::Base
  include AuthoredModel

  belongs_to :control
  belongs_to :implemented_control, :class_name => 'Control'

  is_versioned_ext
end
