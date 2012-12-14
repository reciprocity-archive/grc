class PbcList < ActiveRecord::Base
  include AuthoredModel
  include AuthorizedModel
  include SanitizableAttributes

  attr_accessible :audit_cycle, :title, :audit_firm, :audit_lead, :description, :list_import_date, :status, :notes

  belongs_to :audit_cycle, :class_name => 'Cycle'

  is_versioned_ext

  sanitize_attributes :description, :notes

  validates :title, :audit_cycle,
    :presence => { :message => "needs a value" }

  def display_name
    title
  end
end
