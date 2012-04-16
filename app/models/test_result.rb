# An audit test result
class TestResult < ActiveRecord::Base
  include AuthoredModel

  after_initialize do
    self.passed = false if self.passed.nil?
  end

  validates :title, :passed, :presence => true

  is_versioned_ext

  def display_name
    title
  end
end
