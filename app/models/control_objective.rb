require 'slugged_model'

class ControlObjective
  include DataMapper::Resource
  include DataMapper::Validate
  include SluggedModel
  extend SluggedModel::ClassMethods

  before :save, :upcase_slug

  property :id, Serial
  property :title, String, :required => true
  property :slug, String, :required => true

  validates_with_block :slug do
    validate_slug
  end

  property :description, Text

  has n, :controls, :through => Resource
  belongs_to :regulation

  def self.all_non_company
    all(:regulation => { :company => false })
  end

  def self.all_company
    all(:regulation => { :company => true })
  end

  def self.for_control(control)
    all(:regulation => control.regulation)
  end

  def self.for_system(s)
    all_company
  end

  def company?
    regulation.company?
  end

  def parent
    regulation
  end

  def display_name
    "#{slug} - #{title}"
  end

  def control_ids
    controls.map { |c| c.id }
  end

  def system_ids
    systems.map { |s| s.id }
  end

  property :created_at, DateTime
  property :updated_at, DateTime
end
