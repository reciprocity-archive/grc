class Option < ActiveRecord::Base
  scope :options_for, lambda { |role| where(:role => role) }
end
