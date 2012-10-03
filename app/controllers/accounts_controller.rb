# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class AccountsController < ApplicationController
  include ApplicationHelper

  before_filter :load_account, :only => [:tooltip,
                                         :edit,
                                         :update,
                                         :delete,
                                         :destroy]

  access_control :acl do
    allow :superuser

    actions :new, :create do
      allow :create, :create_account
    end

    actions :edit, :update do
      allow :update, :update_account, :of => :account
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
    role = params[:account].delete(:role)
    @account = Account.new(params[:account])
    @account.role = role

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

  def delete
    @model_stats = []
    @relationship_stats = []

    respond_to do |format|
      format.json { render :json => @account.as_json(:root => nil) }
      format.html do
        render :layout => nil, :template => 'shared/delete_confirm',
          :locals => { :model => @account, :url => flow_account_path(@account), :models => @model_stats, :relationships => @relationship_stats }
      end
    end
  end

  def destroy
    @account.destroy
    flash[:notice] = "Account deleted"
    respond_to do |format|
      format.html { redirect_to programs_dash_path }
      format.json { render :json => @account.as_json(:root => nil) }
    end
  end

  private

  def load_account
    @account = Account.find(params[:id])
  end
end
