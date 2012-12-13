CmsRails::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.cache_classes = true
  config.action_controller.perform_caching = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true

  # Don't care if the mailer can't send
  # config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # hm... these don't work
  #Sass::Plugin.options[:always_update] = true
  #Sass::Plugin.options[:always_check] = true
  #Sass::Plugin.options[:cache] = false

  config.assets.compile = false
  config.assets.digest = true
end
