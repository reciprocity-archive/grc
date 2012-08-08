# An Audit Cycle
#
# Used to group evidence for a particular audit of a program
# start_at is the audit period start date.  If missing, this is a continuous process.
class Cycle < ActiveRecord::Base
  include AuthoredModel

  attr_accessible :program, :start_at, :complete

  # The program being audited
  belongs_to :program

  validates :program, :presence => true
  validates :start_at, :presence => true

  def slug
    program.slug + "-" + (start_at.strftime("%Y-%m-%d") rescue "-")
  end

  def display_name
    program.display_name + " " + (start_at.strftime("%Y-%m-%d") rescue "-")
  end

  is_versioned_ext
end
