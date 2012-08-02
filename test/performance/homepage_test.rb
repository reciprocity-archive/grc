require 'test_helper'
require 'rails/performance_test_help'
load "#{Rails.root}/db/seeds.rb"

class MockUser
  def has_role?(x, y=nil)
    true
  end
  def name
    "name"
  end
  def email
    "email"
  end
end

class UserSession
  def self.find
    UserSession.new
  end
  def record
    MockUser.new
  end
end

class HomepageTest < ActionDispatch::PerformanceTest
  self.profile_options = { :runs => 100, :metrics => [:wall_time],
                           :output => 'tmp/performance', :formats => [:flat] }

  def test_homepage_1
    get '/programs_dash'
  end
  def test_homepage_2
    get '/programs_dash'
  end
end
