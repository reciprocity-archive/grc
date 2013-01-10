class Meeting < ActiveRecord::Base
  include CommonModel

  attr_accessible :response, :start_at, :calendar_url

  belongs_to :response

  is_versioned_ext

  validates_presence_of :response

  def display_name
    "#{response.system.title} meeting"
  end
end
