# Monkey patch to avoid riddle trying to exec stuff
ENV['SPHINX_VERSION'] = '2.0.4'
require 'riddle'
module Riddle
  class Controller
    def sphinx_version
      ENV['SPHINX_VERSION']
    end
  end
end

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
CmsRails::Application.initialize!

#Sass::Plugin.options[:template_location] = { 'app/stylesheets' => 'public/stylesheets' }
