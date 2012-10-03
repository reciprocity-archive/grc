class Transaction < ActiveRecord::Base
  include CommonModel
  include SluggedModel

  attr_accessible :system, :title, :description

  belongs_to :system

  is_versioned_ext

  def display_name
    title
  end
end
