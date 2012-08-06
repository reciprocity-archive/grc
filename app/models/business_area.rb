# A business area (used to classify Controls)
class BusinessArea < ActiveRecord::Base
  include AuthoredModel

  attr_accessible :title

  def display_name
    title
  end

  is_versioned_ext
end
