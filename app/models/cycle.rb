# An Audit Cycle
#
# Used to group evidence for a particular audit of a program
# start_at is the audit period start date.  If missing, this is a continuous process.
class Cycle < ActiveRecord::Base
  include CommonModel
  include AuthorizedModel
  include SanitizableAttributes

  attr_accessible :program, :start_at, :complete, :title, :audit_firm, :audit_lead, :description, :list_import_date, :status, :notes, :end_at

  # The program being audited
  belongs_to :program

  has_many :pbc_lists, :foreign_key => :audit_cycle_id

  sanitize_attributes :description, :notes

  validates :title, :program, :start_at,
    :presence => { :message => "needs a value" }

  is_versioned_ext

  after_create :create_pbc_list

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
    userid.nil? ? nil : Person.where({:id => userid}).first
  end
end
