class Transaction < ActiveRecord::Base
  include CommonModel
  include SanitizableAttributes

  attr_accessible :system, :title, :description

  belongs_to :system

  is_versioned_ext

  sanitize_attributes :description

  def display_name
    title
  end
end
