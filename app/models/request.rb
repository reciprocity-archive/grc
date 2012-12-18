class Request < ActiveRecord::Base
  include AuthoredModel
  include AuthorizedModel
  include SanitizableAttributes

  attr_accessible :pbc_list, :type, :control_assessment, :pbc_control_code, :pbc_control_desc, :request, :test, :notes, :company_responsible, :auditor_responsible, :date_requested, :status

  belongs_to :pbc_list
  belongs_to :control_assessment
  belongs_to :type, :class_name => 'Option', :conditions => { :role => 'request_type' }

  has_one :control, :through => :control_assessment
  has_many :responses, :dependent => :destroy

  is_versioned_ext

  sanitize_attributes :pbc_control_desc, :request, :test, :notes

  validates :pbc_list,
    :presence => { :message => "needs a value" }

  after_save :after_save_detect_orphaned_control_assessment
  after_destroy :after_destroy_detect_orphaned_control_assessment

  def display_name
    pbc_control_code
  end

  def persons_responsible
    [company_responsible, auditor_responsible].compact.join(",")
  end

  def maybe_destroy_orphaned_control_assessment(control_assessment_id)
    old_control_assessment = ControlAssessment.where(
      :id => changed_attributes["control_assessment_id"]).first
    if old_control_assessment && old_control_assessment.requests.count == 0
      old_control_assessment.destroy
    end
  end

  def after_save_detect_orphaned_control_assessment
    if changed_attributes["control_assessment_id"]
      maybe_destroy_orphaned_control_assessment(changed_attributes["control_assessment_id"])
    end
  end

  def after_destroy_detect_orphaned_control_assessment
    maybe_destroy_orphaned_control_assessment(control_assessment_id)
  end
end
