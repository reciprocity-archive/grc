# An audit test result
class TestResult < ActiveRecord::Base
  include AuthoredModel

  validates :title, :passed, :presence => true

  is_versioned_ext

  def display_name
    title
  end
end
