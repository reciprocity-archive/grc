# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

CmsRails::Application.load_tasks

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:coverage) do |t|
    t.fail_on_error = false
    t.spec_opts = %w{--no-drb}
    t.rcov = true
    t.rcov_opts = %w{--no-html -T}
end
