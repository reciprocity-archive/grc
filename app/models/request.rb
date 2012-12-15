class Request < ActiveRecord::Base
  include AuthoredModel
  include AuthorizedModel
  include SanitizableAttributes

  attr_accessible :pbc_list, :type, :control, :pbc_control_code, :pbc_control_desc, :request, :test, :notes, :company_responsible, :auditor_responsible, :date_requested, :status

  belongs_to :pbc_list
  belongs_to :control
  belongs_to :type, :class_name => 'Option', :conditions => { :role => 'request_type' }

  is_versioned_ext

  sanitize_attributes :pbc_control_desc, :request, :test, :notes

  validates :pbc_list,
    :presence => { :message => "needs a value" }

  def display_name
    pbc_control_code
  end

  def persons_resposibile
    [company_responsible, auditor_responsible].compact.join(",")
  end
end
