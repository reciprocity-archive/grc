class ControlControl < ActiveRecord::Base
  include AuthoredModel

  attr_accessible :control, :implemented_control

  belongs_to :control
  belongs_to :implemented_control, :class_name => 'Control'

  is_versioned_ext
end
