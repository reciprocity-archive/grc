class Request < ActiveRecord::Base
  include AuthoredModel
  include AuthorizedModel
  include SanitizableAttributes
  include DatedModel

  TYPES = {
    1 => "Documentation",
    2 => "Population Sample",
    3 => "Interview"
  }

  STATUSES = [
    "Draft",
    "Requested",
    "Responded",
    "Amended/Updated Request",
    "Accepted"
  ]

  attr_accessible :pbc_list, :type_id, :control_assessment, :pbc_control_code, :pbc_control_desc, :request, :test, :notes, :company_responsible, :auditor_responsible, :date_requested, :response_due_at, :status

  belongs_to :pbc_list
  belongs_to :control_assessment
  # removed option type for now, just use hardcoded values (it would cause problems with sync between servers, JS...)
  # belongs_to :type, :class_name => 'Option', :conditions => { :role => 'request_type' }

  has_one :control, :through => :control_assessment
  has_many :responses, :dependent => :destroy

  is_versioned_ext

  sanitize_attributes :pbc_control_desc, :request, :test, :notes

  validates_presence_of :request, :on => :create
  validates_presence_of :type_id
  validates :pbc_list,
    :presence => { :message => "needs a value" }
  validates :company_responsible, :auditor_responsible,
    :allow_blank => true,
    :multi_email => true

  validation_scope :warnings do |s|
    s.validate :validates_request_uniqueness
  end
  
  before_validation :link_control_from_code
  after_save :after_save_detect_orphaned_control_assessment
  after_destroy :after_destroy_detect_orphaned_control_assessment

  def self.types
    TYPES
  end

  def self.statuses
    STATUSES
  end

  def type_name
    if type_id.present?
      TYPES[type_id]
    end
  end

  def display_name
    if pbc_control_code.present?
      pbc_control_code
    elsif control.present?
      control.slug
    else
      "request"
    end
  end

  def display_name_for_delete
    "request"
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

  def self.status_counts(requests)
    counts = Hash[requests.group_by(&:status).map{|x| [x[0], x[1].size]}]

    # Ensure each status is included
    self.statuses.each { |s| counts[s] ||= 0 }

    counts['Draft'] += counts.delete(nil).to_i
    counts
  end

  def validates_request_uniqueness
    r = Request.where(:pbc_list_id => pbc_list_id).
          where(:pbc_control_code => pbc_control_code).
          where(:request => request)

    warnings.add :request, "This request string already exists" if r.any?
  end
  
  def link_control_from_code
    if self.pbc_control_code.present?
      control = Control.where(:slug => self.pbc_control_code).first
      if control 
        if !self.control_assessment.present? || 
          self.control_assessment.presence.control_id != control.id
          #find or create ControlAssesment for given PbcList and Control
          self.control_assessment = ControlAssessment.where(
            :pbc_list_id => pbc_list_id,
            :control_id => control.id).first
          self.control_assessment ||= ControlAssessment.new(
            :pbc_list => pbc_list,
            :control => control)
        end
      end
    end
  end
end
