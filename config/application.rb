require File.expand_path('../boot', __FILE__)

require 'yaml'

CMS_CONFIG = {
  "SECRET_TOKEN" => "0123456789abcdefChangethistosomethingsecret",
  "COMPANY" => "Company, Inc.",
  "COMPANY_LOGO" => nil,
  "COMPANY_LOGO_TEXT" => nil,
  "ABOUT_LINK" => "https://code.google.com/p/compliance-management/",
  "SECTION_IMPORT_TEMPLATE" => nil,
  "CONTROL_IMPORT_TEMPLATE" => nil,
  "ALLOW_HELP_EDIT" => false,
  "DEFAULT_DOMAIN" => "example.com",
  "REQUIRE_SSL" => false,
  "CMS_APP_VERSION" => "s28"
}

CMS_CONFIG["SECRET_TOKEN"] = ENV["SECRET_TOKEN"] if ENV["SECRET_TOKEN"]
CMS_CONFIG["REQUIRE_SSL"]  = ENV["REQUIRE_SSL"]  if ENV["REQUIRE_SSL"]

CMS_CONFIG["COMPANY_LOGO"] = ENV["COMPANY_LOGO"] if ENV["COMPANY_LOGO"]
CMS_CONFIG["COMPANY_LOGO_TEXT"] = ENV["COMPANY_LOGO_TEXT"] if ENV["COMPANY_LOGO_TEXT"]
CMS_CONFIG["COMPANY"] = ENV["COMPANY"] if ENV["COMPANY"]
CMS_CONFIG["ABOUT_LINK"] = ENV["ABOUT_LINK"] if ENV["ABOUT_LINK"]
CMS_CONFIG["FULLTEXT"] = ENV["FULLTEXT"] if ENV["FULLTEXT"]
CMS_CONFIG["ALLOW_HELP_EDIT"] = ENV["ALLOW_HELP_EDIT"] if ENV["ALLOW_HELP_EDIT"]
CMS_CONFIG["DEFAULT_DOMAIN"] = ENV["DEFAULT_DOMAIN"] if ENV["DEFAULT_DOMAIN"]
CMS_CONFIG["CMS_APP_VERSION"] = ENV["CMS_APP_VERSION"] if ENV["CMS_APP_VERSION"]

# Use the new variable name if available; fallback to deprecated name if not
CMS_CONFIG["SECTION_IMPORT_HELP_LINK"] = ENV["SECTION_IMPORT_HELP_LINK"] if ENV["SECTION_IMPORT_HELP_LINK"]
CMS_CONFIG["SECTION_IMPORT_HELP_LINK"] ||= ENV["SECTION_IMPORT_TEMPLATE"] if ENV["SECTION_IMPORT_TEMPLATE"]
CMS_CONFIG["CONTROL_IMPORT_HELP_LINK"] = ENV["CONTROL_IMPORT_HELP_LINK"] if ENV["CONTROL_IMPORT_HELP_LINK"]
CMS_CONFIG["CONTROL_IMPORT_HELP_LINK"] ||= ENV["CONTROL_IMPORT_TEMPLATE"] if ENV["CONTROL_IMPORT_TEMPLATE"]
CMS_CONFIG["SYSTEM_IMPORT_HELP_LINK"] = ENV["SYSTEM_IMPORT_HELP_LINK"] if ENV["SYSTEM_IMPORT_HELP_LINK"]
CMS_CONFIG["SYSTEM_IMPORT_HELP_LINK"] ||= ENV["SYSTEM_IMPORT_TEMPLATE"] if ENV["SYSTEM_IMPORT_TEMPLATE"]
CMS_CONFIG["PBC_LIST_IMPORT_HELP_LINK"] = ENV["PBC_LIST_IMPORT_HELP_LINK"] if ENV["PBC_LIST_IMPORT_HELP_LINK"]
CMS_CONFIG["PBC_LIST_IMPORT_HELP_LINK"] ||= ENV["PBC_LIST_IMPORT_TEMPLATE"] if ENV["PBC_LIST_IMPORT_TEMPLATE"]
CMS_CONFIG["RISK_IMPORT_HELP_LINK"] = ENV["RISK_IMPORT_HELP_LINK"] if ENV["RISK_IMPORT_HELP_LINK"]
CMS_CONFIG["RISK_IMPORT_HELP_LINK"] ||= ENV["RISK_IMPORT_TEMPLATE"] if ENV["RISK_IMPORT_TEMPLATE"]

require 'rails/all'

#
# HACK: Load sprockets, and then delete the .ejs engine.
# This keeps sprockets from trying (and failing) to compile the
# ejs templates on the server.
#
require 'sprockets'
module ::Sprockets
  @engines.delete('.ejs')
end

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module CmsRails
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{config.root}/app/models/cache)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.action_view.javascript_expansions[:defaults] = %w(jquery jquery-ujs jquery-ui jquery.multiselect jquery.manyselect jquery.multiselect.filter)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]
    config.assets.precompile += ['dashboard.css', 'dashboard.js', 'admin.css', 'admin.js', 'design.css', 'design.js']

    # Enable the asset pipeline
    config.assets.enabled = true

    # Prevent initializing the database during asset compilation on Heroku
    config.assets.initialize_on_precompile = false

    # Version of your assets, change this if you want to expire all your assets
    #config.assets.version = '1.0'

    config.generators do |g|
      # Haml generator
      g.template_engine :haml
    end

    config.active_record.mass_assignment_sanitizer = :strict

  end
end

begin
  require File.expand_path('../application-local', __FILE__)
rescue LoadError
  puts "no application-local, or caught exception"
end
