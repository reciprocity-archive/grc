class Option < ActiveRecord::Base
  include AuthoredModel

  attr_accessible :role, :title, :description

  def to_s
    title
  end

  scope :options_for, lambda { |role| where(:role => role) }

  is_versioned_ext
end
