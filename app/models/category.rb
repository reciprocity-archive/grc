class Category < ActiveRecord::Base
  include AuthoredModel

  attr_accessible :name, :scope_id, :parent, :required

  scope :ctype, lambda { |sid| where(:scope_id => sid) }
  acts_as_nested_set :scope => :scope_id

  has_many :categorizations, :dependent => :destroy
  has_many :controls, :through => :categorizations,
    :source => :categorizable, :source_type => 'Control'

  is_versioned_ext

  def display_name
    name
  end

  def parent_name
    parent && parent.name
  end

  def as_json(options={})
    super(options.merge(:methods => :parent_name))
  end

  def self.db_search(q)
    q = "%#{q}%"
    t = arel_table
    where(t[:name].matches(q))
  end
end
