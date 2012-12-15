class Response < ActiveRecord::Base
  include AuthoredModel
  include AuthorizedModel

  attr_accessible :request, :system, :status

  belongs_to :request
  belongs_to :system

  is_versioned_ext

  validates :request, :system,
    :presence => { :message => "needs a value" }

  def display_name
    "#{request.pbc_control_code} - #{system.title}"
  end
end
