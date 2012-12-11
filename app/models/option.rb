class Option < ActiveRecord::Base
  include AuthoredModel

  attr_accessible :role, :title, :description, :required

  def to_s
    title
  end

  scope :options_for, lambda { |role| where(:role => role) }

  is_versioned_ext

  def display_name
    title
  end

  def self.db_search(q)
    q = "%#{q}%"
    t = arel_table
    where(t[:role].matches(q))
  end
end
