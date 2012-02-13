require 'slugged_model'

# A control objective (inverse of risk)
#
# Hierarchically, a CO has Regulation as a parent and has Controls
# as children.
#
# The slug of a CO has to have the slug of the regulation as prefix.
class ControlObjective
  include DataMapper::Resource
  include DataMapper::Validate
  include SluggedModel
  extend SluggedModel::ClassMethods

  before :save, :upcase_slug

  property :id, Serial
  property :title, String, :required => true, :length => 255
  property :slug, String, :required => true

  validates_with_block :slug do
    validate_slug
  end

  property :description, Text

  has n, :controls, :through => Resource, :order => :slug
  belongs_to :regulation

  # All COs associated with a regulation
  def self.all_non_company
    all(:regulation => { :company => false }, :order => :slug)
  end

  # All COs associated with a company "regulation"
  def self.all_company
    all(:regulation => { :company => true }, :order => :slug)
  end

  # All COs that could be associated with a control (in same regulation)
  def self.for_control(control)
    all(:regulation => control.regulation, :order => :slug)
  end

  # All COs that could be associated with a system (any company CO)
  def self.for_system(s)
    all_company
  end

  # Whether this CO is associated with a company "regulation"
  def company?
    regulation.company?
  end

  # The parent
  def parent
    regulation
  end

  def display_name
    "#{slug} - #{title}"
  end

  # Return ids of related Controls (used by many2many widget)
  def control_ids
    controls.map { |c| c.id }
  end

  # Return ids of related Systems (used by many2many widget)
  def system_ids
    systems.map { |s| s.id }
  end

  property :created_at, DateTime
  property :updated_at, DateTime
end
