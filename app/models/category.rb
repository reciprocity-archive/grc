class Category < ActiveRecord::Base
  include AuthoredModel

  scope :ctype, lambda { |sid| where(:scope_id => sid) }
  acts_as_nested_set :scope => :scope_id

  attr_accessible :name, :scope_id, :parent

  has_many :categorizations, :dependent => :destroy
  has_many :controls, :through => :categorizations,
    :source => :categorizable, :source_type => 'Control'

  is_versioned_ext

  def parent_name
    parent && parent.name
  end

  def as_json(options={})
    super(options.merge(:methods => :parent_name))
  end
end
