class Category < ActiveRecord::Base
  include AuthoredModel

  attr_accessible :name, :scope_id, :parent, :required

  scope :ctype, lambda { |sid| where(:scope_id => sid) }
  acts_as_nested_set :scope => :scope_id, :dependent => :destroy

  has_many :categorizations, :dependent => :destroy
  has_many :controls, :through => :categorizations,
    :source => :categorizable, :source_type => 'Control'
  has_many :risks, :through => :categorizations,
    :source => :categorizable, :source_type => 'Risk'

  is_versioned_ext

  def display_name
    name
  end

  def parent_name
    parent && parent.name
  end

  def ancestor_names
    ancestors.map(&:display_name).join(",")
  end

  def get_path
    self_and_ancestors.map { |node| node.name }.join("/")
  end

  def as_json(options={})
    super(options.merge(:methods => :parent_name))
  end

  def as_csv
    row_values = []
    self.class.attribute_names_for_csv.each do |attr|
      row_values << self.send(attr)
    end
    CSV.generate_line(row_values)
  end

  def self.attribute_names_for_csv
    ["ancestor_names"] + Category.attribute_names - ["lft", "rgt", "id", "parent_id"]
  end

  def self.db_search(q)
    q = "%#{q}%"
    t = arel_table
    where(t[:name].matches(q))
  end
end
