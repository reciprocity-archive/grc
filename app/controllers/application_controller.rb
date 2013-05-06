# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2011
# License:: Apache 2.0

# This class is the base for all controllers used in this app

#require 'dm-rails/middleware/identity_map'
class ApplicationController < ActionController::Base
  include ApplicationHelper
  include AuthorizationHelper
  include FormHelper

  before_filter :redirect_to_https if CMS_CONFIG['REQUIRE_SSL']

  before_filter :require_user
  before_filter :set_features
  before_filter  :set_default_cache_control

  after_filter  :ajax_flash_to_headers
  after_filter  :ajax_redirect_to_headers

  #use Rails::DataMapper::Middleware::IdentityMap
  protect_from_forgery

  helper_method :current_user_session, :current_user

  # By default allow only superuser access.  This is relaxed in specific controllers.
#  access_control :acl do
#    allow :superuser
#  end

  def redirect_to_https
    redirect_to :protocol => "https://" unless (request.ssl? || request.local?)
  end

  rescue_from Acl9::AccessDenied do
    # FIXME: This should probably render a page more specific to
    # 403s, especially for AJAXy stuff.
    render_unauthorized
  end

  def render_unauthorized
    render :text => "You don't have sufficient privileges to view this.", :status => :unauthorized
#    flash[:warning] = "You are not authorized to access this page"
#    if request.xhr?
#      render :partial => 'error/unauthorized', :layout => nil, :status => 403
#    else
#      render :template => 'error/unauthorized', :status => 403
#    end
  end

  def render_unauthenticated
    flash[:notice] = "You must be logged in to access this page"
    render :template => 'error/unauthenticated', :layout => 'welcome', :status => 401
  end

  private

  def set_features
    if params[:BETA].present? && params[:BETA] != session[:BETA]
      session[:BETA] = params[:BETA]
      redirect_to request.fullpath.gsub(/BETA=[^&]*&?/, '').sub(/[?&]$/, '')
    else
      @_features = {
        :BETA => session[:BETA] == '1'
      }
    end
  end

  # The current user session or nil
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
    @current_user_session
  end

  # The current user or nil
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
    @current_user
  end

  # Pre-filter for requiring the user to be logged in.  On by default.
  def require_user
    unless current_user && current_user.is_active?
      store_location
      render_unauthenticated
      return false
    end

  end

  # Memoize current request location so that we can return to it after a redirect
  def store_location
    session[:return_to] = request.fullpath
  end

  # Redirect back to memoized location
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  before_filter :check_ssl

  def check_ssl
    # FIXME properly check if we are behind an SSL proxy
    #  request.env['HTTPS'] = 'on' if Rails.env.production?
  end

  def set_cache_control(value)
    headers["Cache-Control"] = value
  end

  def set_default_cache_control
    set_cache_control("private, no-cache, no-store, must-revalidate")
  end

  def ajax_refresh
    render :text => "", :status => 279

    flash.keep
  end

  # Move flash messages to HTTP headers
  def ajax_flash_to_headers
    # Only if AJAX request
    return unless request.xhr?

    # FIXME: Use only one of these -- consolidated is better(?), but separated
    # is used more.

    # Separated flash messages
    [:error, :alert, :warning, :notice].each do |type|
      if flash[type]
        response.headers["X-Flash-#{type.capitalize}"] = flash[type].to_json
      end
    end

    # Consolidated flash messages
    flash_json = Hash[flash.map{|k,v| [k,ERB::Util.h(v)] }].to_json
    response.headers['X-Flash-Messages'] = flash_json

    # Don't discard for redirect, ajax-redirect, or ajax-refresh
    unless @keep_flash_after_import
      flash.discard unless [302, 278, 279].include?(response.status)
    end
  end

  def keep_flash_after_import
    # This is only used to not discard flash messages after imports
    @keep_flash_after_import = true
  end

  # Change redirect status code for AJAX redirects
  def ajax_redirect_to_headers
    return unless request.xhr?

    if response.status == 302
      response.status = 278
    end
  end

  def log_backtrace(e)
    # http://stackoverflow.com/questions/228441/how-do-i-log-the-entire-trace-back-of-a-ruby-exception-using-the-default-rails-l
    if backtrace = e.backtrace
      gem_home = ENV['GEM_HOME']
      rvm_home = ENV['MY_RUBY_HOME']
      backtrace = backtrace.map do |line|
        line = line.sub(gem_home, '$GEM_HOME') if gem_home.present?
        line = line.sub(rvm_home, '$MY_RUBY_HOME') if rvm_home.present?
        line = line.sub(Rails.root.to_s, '')
      end
    end

    logger.error(
      "\n\n#{e.class} (#{e.message}):\n    " +
      backtrace.join("\n    ") + "\n\n" )
  end
end
