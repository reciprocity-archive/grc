# An Audit Cycle
#
# Used to group evidence for a particular audit of a program
# start_at is the audit period start date.  If missing, this is a continuous process.
class Cycle < ActiveRecord::Base
  include CommonModel

  attr_accessible :program, :start_at, :complete

  # The program being audited
  belongs_to :program

  has_many :pbc_lists, :foreign_key => :audit_cycle_id

  validates :program, :presence => true
  validates :start_at, :presence => true

  is_versioned_ext

  def display_name
    program.display_name + " " + (start_at.strftime("%Y-%m-%d") rescue "-")
  end

  def slug
    program.slug + "-" + (start_at.strftime("%Y-%m-%d") rescue "-")
  end
end
