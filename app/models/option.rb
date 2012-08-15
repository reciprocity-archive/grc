class Option < ActiveRecord::Base
  attr_accessible :role, :title

  scope :options_for, lambda { |role| where(:role => role) }
end
