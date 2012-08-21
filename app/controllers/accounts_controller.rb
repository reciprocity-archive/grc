# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class AccountsController < ApplicationController
  include ApplicationHelper

  before_filter :load_account, :only => [:tooltip,
                                         :edit,
                                         :update]

  access_control :acl do
    allow :superuser, :admin, :analyst

    actions :new, :create do
      allow :create_account
    end

    actions :edit, :update do
      allow :update_account, :of => :account
    end
  end

  layout 'dashboard'

  def new
    @account = Account.new(params[:account])

    render :layout => nil
  end

  def edit
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

  private

  def load_account
    @account = Account.find(params[:id])
  end
end
