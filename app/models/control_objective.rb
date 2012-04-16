require 'slugged_model'

# A control objective (inverse of risk)
#
# Hierarchically, a CO has Regulation as a parent and has Controls
# as children.
#
# The slug of a CO has to have the slug of the regulation as prefix.
class ControlObjective < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel

  before_save :upcase_slug

  #validates_presence_of :title
  #validates_presence_of :slug

  validate :slug do
    validate_slug
  end

  has_many :controls, :through => :control_control_objectives, :order => :slug
  has_many :control_control_objectives
  belongs_to :regulation

  # All COs associated with a regulation
  def self.all_non_company
    joins(:regulation).where(:regulations => { :company => false }).order(:slug)
  end

  # All COs associated with a company "regulation"
  def self.all_company
    joins(:regulation).where(:regulations => { :company => true }).order(:slug)
  end

  # All COs that could be associated with a control (in same regulation)
  def self.for_control(control)
    where(:regulation_id => control.regulation_id).order(:slug)
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

  is_versioned_ext
end
