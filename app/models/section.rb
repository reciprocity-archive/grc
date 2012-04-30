require 'slugged_model'

# A control objective (inverse of risk)
#
# The slug of a Section has to have the slug of the parent as prefix.
class Section < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel

  before_save :upcase_slug

  #validates_presence_of :title
  #validates_presence_of :slug

  validate :slug do
    validate_slug
  end

  has_many :controls, :through => :control_sections, :order => :slug
  has_many :control_sections
  belongs_to :program
  belongs_to :parent, :class_name => "Section"

  # All Sections that could be associated with a control (in same program)
  def self.for_control(control)
    where(:program_id => control.program_id).order(:slug)
  end

  # All Sections that could be associated with a system (any company Section)
  def self.for_system(s)
    all
  end

  # Whether this Section is associated with a company "program"
  def company?
    program.company?
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

  is_versioned_ext
end
