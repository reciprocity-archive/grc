# Uncomment or put the following in Gemfile.local
# source 'http://rubygems.org'

if File.exist? 'Gemfile.local'
  instance_eval(Bundler.read_file('Gemfile.local'), 'Gemfile.local', 1)
end

RAILS_VERSION = '= 3.2.12'

# Fulltext search
gem 'thinking-sphinx', '~> 2.0.14'

gem 'remotipart'

#gem 'gdata-ruby-util', '1.1.2'
gem 'gdata_19', '~> 1.1.5', :require => 'gdata'

platforms :jruby do
  gem 'jruby-rack', '= 1.1.9'
end


platforms :ruby do
  group :development, :test do
    gem 'sqlite3'
  end

  group :heroku do
    gem "pg"
  end

  group :staging do
    gem "mysql2"
  end

  group :production do
    gem "mysql2"
  end
end

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter'
  gem 'activerecord-jdbcmysql-adapter'

  group :development do
    gem 'warbler', '1.3.5'
    gem 'jruby-openssl'
    gem 'therubyrhino'
  end
end

gem 'encrypted-cookie-store'
gem 'strict-forgery-protection'
gem 'authlogic'
gem 'builder'
gem 'json', '~> 1.7.7'

gem 'acl9'

gem 'rails', RAILS_VERSION

gem 'haml', '~> 3.2.0.beta.2'
gem 'haml-rails'

group :assets do
  gem 'sass', '~> 3.2.0'
  gem 'sass-rails'
  gem 'compass-rails'
  gem 'bootstrap-sass', '~> 2.0.4.2'
end

# Used to be pulled in by dm-types
gem 'bcrypt-ruby'

gem 'prawn' # PDF generation

gem 'paper_trail', '~> 2'

gem 'awesome_nested_set'

group(:development, :test) do

  # Uncomment this if you want to use rspec for testing your application

  gem 'rspec-rails'
  gem 'spork', '~> 0.9.0.rc'
  # Don't update to ZenTest 4.8.4 because it breaks rubygems
  # https://github.com/seattlerb/zentest/issues/28
  gem 'ZenTest', '< 4.8.4'
  gem 'autotest-rails'
  gem 'simplecov', :require => false
  gem 'capybara'

  gem 'factory_girl_rails', "~> 4.0"

  gem 'therubyracer', "~> 0.10.2"
  gem 'jasminerice'
  gem 'guard-jasmine'
  gem 'jasmine-jquery-rails'

  # To get a detailed overview about what queries get issued and how long they take
  # have a look at rails_metrics. Once you bundled it, you can run
  #
  #   rails g rails_metrics Metric
  #   rake db:automigrate
  #
  # to generate a model that stores the metrics. You can access them by visiting
  #
  #   /rails_metrics
  #
  # in your rails application.

  # gem 'rails_metrics', '~> 0.1', :git => 'git://github.com/engineyard/rails_metrics'

# Uncomment or paste into Gemfile.local
#
#  platform :jruby do
#    gem 'ruby-debug'
#  end
#
  platform :ruby do
#    gem 'linecache19'
#    gem 'ruby-debug-base19x', '~> 0.11.30.pre4'
#    gem 'ruby-debug19', :require => 'ruby-debug'
    gem 'ruby-prof'
  end

  # Causes rake to fail, uncomment to rebuild docs
  # gem 'yard-dm'
  # gem 'yard'
  # gem 'redcarpet'
  gem 'test-unit'
end
