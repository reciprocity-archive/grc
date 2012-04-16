# A business process involves multiple systems and is controlled by multiple controls
# and control objectives.
class BizProcess < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  extend SluggedModel::ClassMethods

  before_save :upcase_slug

  validates :title, :slug, :presence => true

  has_many :systems, :through => :biz_process_systems, :order => :slug
  has_many :biz_process_systems
  has_many :control_objectives, :through => :biz_process_control_objectives, :order => :slug
  has_many :biz_process_control_objectives
  has_many :controls, :through => :biz_process_controls, :order => :slug
  has_many :biz_process_controls

  # Responsible party
  belongs_to :owner, :class_name => 'Person'

  # Other parties
  has_many :biz_process_persons
  has_many :persons, :through => :biz_process_persons

  has_many :policies, :class_name => 'Document', :through => :biz_process_documents 
  has_many :biz_process_documents

  # TODO(miron) business units

  is_versioned_ext

  # All biz processes that could be attached to a system
  def self.for_system(s)
    where({})
  end

  # Return ids of related COs (used by many2many widget)
  def co_ids
    control_objectives.map { |co| co.id }
  end

  # Return ids of related Controls (used by many2many widget)
  def control_ids
    controls.map { |c| c.id }
  end

  # Return ids of related Systems (used by many2many widget)
  def system_ids
    systems.map { |s| s.id }
  end

  def display_name
    "#{slug} - #{title}"
  end
end
