class WelcomeController < ApplicationController
  skip_before_filter :require_user

  access_control :acl do
    allow all
  end

  def index
    session[:return_to] = login_dispatch_path
  end

  def login_dispatch
    if current_user.role == "auditor"
      redirect_to placeholder_path
    else
      redirect_to dashboard_index_path
    end
  end
end
