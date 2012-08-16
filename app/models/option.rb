class Option < ActiveRecord::Base
  include AuthoredModel

  attr_accessible :role, :title, :description

  scope :options_for, lambda { |role| where(:role => role) }

  is_versioned_ext
end
