class WelcomeController < ApplicationController
  skip_before_filter :require_user

  access_control :acl do
    allow all
  end

  def index
    session[:return_to] = login_dispatch_path
    if current_user
      redirect_to programs_dash_path
    end
  end

  def login_dispatch
    if current_user.nil?
      redirect_to :action => :index
    elsif current_user.role == "auditor"
      redirect_to placeholder_path
    else
      redirect_to programs_dash_path
    end
  end
end
