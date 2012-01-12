# An audit test result
class TestResult
  include DataMapper::Resource

  property :id, Serial
  property :title, String, :required => true
  property :passed, Boolean, :required => true, :default => false
  property :output, Text

  property :created_at, DateTime
  property :updated_at, DateTime

  is_versioned :on => [:updated_at]

  def display_name
    title
  end
end
