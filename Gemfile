source 'http://rubygems.org'

if File.exist? 'Gemfile.local'
  instance_eval(Bundler.read_file('Gemfile.local'), 'Gemfile.local', 1)
end

RAILS_VERSION = '~> 3.1.1'
DM_VERSION    = '~> 1.2.0'

gem 'gdata', '1.1.2', :path => ENV['HOME'] + '/localgems/gdata'

platforms :ruby do
  gem 'sqlite3'
end

platforms :jruby do
  gem 'jdbc-sqlite3', :require => false
  gem 'jdbc-mysql', :require => false
  gem 'jruby-openssl'
  gem 'therubyrhino'
end

group(:production) do
  gem 'dm-mysql-adapter',     DM_VERSION
end

gem 'authlogic'
#gem 'dalli'
gem 'builder'
gem 'json'

gem 'acl9'

gem 'activesupport',      RAILS_VERSION, :require => 'active_support'
gem 'actionpack',         RAILS_VERSION, :require => 'action_pack'
gem 'actionmailer',       RAILS_VERSION, :require => 'action_mailer'
gem 'railties',           RAILS_VERSION, :require => 'rails'

gem 'haml', '~> 3.0.25'
gem 'sass'
gem 'haml-rails'

gem 'prawn' # PDF generation

gem 'dm-rails',          :path => ENV['HOME'] + '/localgems/dm-rails'
gem 'dm-sqlite-adapter', DM_VERSION

gem 'dm-migrations',        DM_VERSION
gem 'dm-types',             DM_VERSION
gem 'dm-validations',       DM_VERSION
gem 'dm-constraints',       DM_VERSION
gem 'dm-transactions',      DM_VERSION
gem 'dm-aggregates',        DM_VERSION
gem 'dm-timestamps',        DM_VERSION
gem 'dm-observer',          DM_VERSION
#gem 'dm-is-versioned',      '1.3.0.beta', :git => 'http://github.com/devrandom1/dm-is-versioned.git'
gem 'dm-is-versioned',      '1.3.0.beta', :path => '../dm-is-versioned'

group(:development, :test) do

  # Uncomment this if you want to use rspec for testing your application

  gem 'rspec-rails'
  gem 'spork', '~> 0.9.0.rc'
  gem 'ZenTest'
  gem 'rcov'

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

  platform :jruby do
    gem 'ruby-debug'
  end
  platform :ruby do
    gem 'ruby-debug19'
  end
end

# Causes rake to fail, uncomment to rebuild docs
#gem 'yard-dm'
gem 'yard'
gem 'redcarpet'
