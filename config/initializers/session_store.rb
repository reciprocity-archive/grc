# Be sure to restart your server when you modify this file.

require 'dm-rails/session_store'

# Store sessions in the database, managed by Datamapper
CmsRails::Application.config.session_store Rails::DataMapper::SessionStore, :secure => Rails.env.production?, :key => '_cms_session_id'
