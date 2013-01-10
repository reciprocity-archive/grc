class PbcList < ActiveRecord::Base
  include AuthoredModel
  include AuthorizedModel
  include SanitizableAttributes

  attr_accessible :audit_cycle

  belongs_to :audit_cycle, :class_name => 'Cycle'

  has_many :requests, :dependent => :destroy
  has_many :control_assessments, :dependent => :destroy

  is_versioned_ext

  def display_name
    audit_cycle.title
  end

  def request_stats
    counts = Request.status_counts(self.requests.all)
    total = counts.values.sum
    percentages = {}
    counts.each do |k, v|
      percentages[k] = (100.0 * v) / total
    end
    [counts, percentages]
  end
end
