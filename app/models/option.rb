class Option < ActiveRecord::Base
  scope :control_type_options, lambda { where(:role => 'control_type') }
  scope :control_kind_options, lambda { where(:role => 'control_kind') }
  scope :control_means_options, lambda { where(:role => 'control_means') }

  scope :system_type_options, lambda { where(:role => 'system_type') }
end
