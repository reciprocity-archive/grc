# An Audit Cycle
#
# Used to group evidence for a particular audit of a regulation
# start_at is the audit period start date.  If missing, this is a continuous process.
class Cycle < ActiveRecord::Base
  include AuthoredModel

  after_initialize do
    self.complete = false if self.complete.nil?
  end

  # The regulation being audited
  belongs_to :regulation

  validates :regulation, :presence => true

  def slug
    regulation.slug + "-" + (start_at.strftime("%Y-%m-%d") rescue "-")
  end

  def display_name
    regulation.display_name + " " + (start_at.strftime("%Y-%m-%d") rescue "-")
  end

  is_versioned_ext
end
