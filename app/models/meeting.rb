class Meeting < ActiveRecord::Base
  include CommonModel

  attr_accessible :response, :start_at, :calendar_url

  belongs_to :response

  is_versioned_ext

  validates_presence_of :response, :calendar_url

  def display_name
    "#{response.system.title} meeting"
  end

  def calendar_url
    self[:calendar_url].gsub "action=TEMPLATE&tmeid=", "action=VIEW&eid="
  end

end
