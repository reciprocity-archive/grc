# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class AccountsController < ApplicationController
  include ApplicationHelper

  access_control :acl do
    allow :superuser, :admin, :analyst
  end

  layout 'dashboard'

  def tooltip
    @account = Account.find(params[:id])
    render :layout => nil
  end

  def create
    @account = Account.new(params[:account])

    respond_to do |format|
      if @account.save
        flash[:notice] = "Successfully created a new account."
        format.html { ajax_refresh }
      else
        flash[:error] = @account.errors.full_messages
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    @account = Account.new(params[:id])

    respond_to do |format|
      if @account.authored_update(current_user, params[:account])
        flash[:notice] = "Successfully updated the account."
        format.html { ajax_refresh }
      else
        flash[:error] = @account.errors.full_messages
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end
end
