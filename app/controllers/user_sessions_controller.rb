class UserSessionsController < ApplicationController
  skip_before_filter :require_user, :except => :destroy
  
  #before_filter :require_no_user, :only => [:new, :create]
  #before_filter :require_user, :only => :destroy

  layout 'welcome'
  
  access_control :acl do
    allow all
  end

  def login
    if current_user
      flash[:notice] = "You are already logged in. Log in as a different user?"
    end
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default root_url
    else
      flash[:error] = "Login failed!"
      render :action => 'login', :status => 401
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default root_url
  end
end
