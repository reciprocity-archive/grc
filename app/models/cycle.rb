# An Audit Cycle
#
# Used to group evidence for a particular audit of a program
# start_at is the audit period start date.  If missing, this is a continuous process.
class Cycle < ActiveRecord::Base
  include CommonModel
  include AuthorizedModel
  include SanitizableAttributes
  include DatedModel

  attr_accessible :program, :start_at, :complete, :title, :audit_firm, :audit_lead, :description, :list_import_date, :status, :notes, :end_at, :report_due_at

  # The program being audited
  belongs_to :program

  has_many :pbc_lists, :foreign_key => :audit_cycle_id

  sanitize_attributes :description, :notes

  validates :title, :program, :program_id, :start_at,
    :presence => { :message => "needs a value" }

  validate :validate_report_due_after_start_at

  is_versioned_ext

  after_create :create_pbc_list

  def validate_report_due_after_start_at
    errors.add(:report_due_at, "must be on or after start date") if report_due_at.present? && start_at.present? && report_due_at < start_at
  end

  def display_name
    program.display_name + " " + (start_at.strftime("%Y-%m-%d") rescue "-")
  end

  def slug
    program.slug + "-" + (start_at.strftime("%Y-%m-%d") rescue "-")
  end

  def create_pbc_list
    pbc_list = PbcList.new
    pbc_list.audit_cycle = self
    pbc_list.save
  end

  def created_by
    userid = Version.where({:item_id => self[:id], :item_type => self.class.name}).first[:whodunnit] rescue nil
    userid.nil? ? modified_by : Person.where({:id => userid}).first
  end

  def ca_request_stats
    cas = []
    rqs = []
    scs = {}
    total_sc = 0
    self.pbc_lists.each do |pbc_list|
      cas.concat pbc_list.requests.map{|rq| rq.control_assessment}
      rqs.concat pbc_list.requests
      status_counts, status_percentages = pbc_list.request_stats
      Request.statuses.each do |status|
        scs[status] = (scs[status].nil? ? 0 : scs[status]) + status_counts[status]
        total_sc += status_counts[status]
      end
    end
    cas = cas.uniq
    [cas.count, rqs.count, scs, scs.merge(scs){|k, sc| total_sc == 0 ? 0 : sc * 100 / total_sc}]
  end
end
