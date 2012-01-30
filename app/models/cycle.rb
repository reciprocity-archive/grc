# An Audit Cycle
#
# Used to group evidence for a particular audit of a regulation
class Cycle
  include DataMapper::Resource
  include AuthoredModel

  property :id, Serial

  # The regulation being audited
  belongs_to :regulation, :required => true

  # When the audit period start date.  If missing, this is a continuous process.
  property :start_at, Date

  # Whether the audit is archived (no modifications allowed)
  property :complete, Boolean, :default => false, :required => true

  def display_name
    regulation.display_name + " " + display_time(start_at)
  end

  property :created_at, DateTime
  property :updated_at, DateTime

  is_versioned_ext :on => [:updated_at]
end
