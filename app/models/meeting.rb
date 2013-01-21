class Meeting < ActiveRecord::Base
  include CommonModel

  attr_accessible :response, :start_at, :calendar_url

  belongs_to :response

  is_versioned_ext

  validates_presence_of :response

  def display_name
    "#{response.system.title} meeting"
  end

  def calendar_url=(url)
    self[:calendar_url] = url.gsub "action=TEMPLATE&tmeid=", "action=VIEW&eid="
  end

end
