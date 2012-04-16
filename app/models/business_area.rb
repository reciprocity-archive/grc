# A business area (used to classify Controls)
class BusinessArea < ActiveRecord::Base
  include AuthoredModel

  def display_name
    title
  end

  is_versioned_ext
end
