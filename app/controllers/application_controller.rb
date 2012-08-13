# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2011
# License:: Apache 2.0

# This class is the base for all controllers used in this app

#require 'dm-rails/middleware/identity_map'
class ApplicationController < ActionController::Base
  include ApplicationHelper

  before_filter :require_user
  before_filter :filter_set
  after_filter :flash_to_headers

  after_filter  :ajax_flash_to_headers
  after_filter  :ajax_redirect_to_headers

  #use Rails::DataMapper::Middleware::IdentityMap
  protect_from_forgery

  helper_method :current_user_session, :current_user

  # By default allow only admin access.  This is relaxed in specific controllers.
  access_control :acl do
    allow :admin, :superuser
  end

  rescue_from Acl9::AccessDenied do
      flash[:warning] = "You are not authorized to access this page"
      redirect_to root_url
      return false
  end

  private

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
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to login_url
      return false
    end
  end

  # Pre-filter for requiring the user to not be logged in
  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to root_url
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

  # Set the program to filte rby if the user selected one on previous page.  This is
  # a before filter that is always on, since the program filter pulldown appears on
  # many pages.
  def filter_set
    if session[:program_id]
      @program = Program.where(:id => session[:program_id]).first
    end
    if session[:company_id]
      @company = Program.where(:id => session[:company_id]).first
    end
    if params[:cycle_id]
      session[:cycle_id] = params[:cycle_id]
    end
    if session[:cycle_id]
      @cycle = Cycle.where(:id => params[:cycle_id] || session[:cycle_id]).first
    end
  end

  before_filter :check_ssl

  def check_ssl
    # FIXME properly check if we are behind an SSL proxy
    #  request.env['HTTPS'] = 'on' if Rails.env.production?
  end

  def need_cycle
    unless @cycle
      render 'base/need_cycle'
      return false
    end
    return true
  end

  def flash_to_headers
    if request.xhr?
      flash_json = Hash[flash.map{|k,v| [k,ERB::Util.h(v)] }].to_json
      response.headers['X-Flash-Messages'] = flash_json
      flash.discard
    end
  end

  def ajax_refresh
    render :text => "", :status => 279

    flash.keep
  end

  # Move flash messages to HTTP headers
  def ajax_flash_to_headers
    # Only if AJAX request
    return unless request.xhr?

    # Not if AJAX redirect
    #return if [302, 278, 279].include?(response.status)

    [:error, :alert, :warning, :notice].each do |type|
      if flash[type]
        response.headers["X-Flash-#{type.capitalize}"] = flash[type].to_json
      end
    end

    flash.discard unless [302, 278, 279].include?(response.status)
  end

  # Change redirect status code for AJAX redirects
  def ajax_redirect_to_headers
    return unless request.xhr?

    if response.status == 302
      response.status = 278
    end
  end
end
