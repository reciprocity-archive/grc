class Category < ActiveRecord::Base
  scope :ctype, lambda { |sid| where(:scope_id => sid) }
  acts_as_nested_set :scope => :scope_id

  attr_accessible :name, :scope_id
end
