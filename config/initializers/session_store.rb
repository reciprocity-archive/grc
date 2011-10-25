# Be sure to restart your server when you modify this file.

#CmsRails::Application.config.session_store :cookie_store, :key => '_cms-rails_session'

#require 'action_dispatch/middleware/session/dalli_store'

#CmsRails::Application.config.session_store :dalli_store, :memcache_server => ['localhost'], :namespace => 'sessions', :key => '_cms_session', :expire_after => 2.days
#

require 'dm-rails/session_store'
CmsRails::Application.config.session_store Rails::DataMapper::SessionStore

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# CmsRails::Application.config.session_store :active_record_store
