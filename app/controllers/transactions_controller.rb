# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle Transactions
class TransactionsController < ApplicationController
  include ApplicationHelper

  access_control :acl do
    allow :superuser, :admin, :analyst
  end

  layout 'dashboard'

  def edit
    @transaction = Transaction.find(params[:id])
    render :layout => nil
  end

  def new
    @transaction = Transaction.new(params[:transaction])
    render :layout => nil
  end

  def create
    @transaction = Transaction.new(params[:transaction])

    respond_to do |format|
      if @transaction.save
        flash[:notice] = "Successfully created a new transaction."
        format.json do
          render :json => @transaction.as_json(:root => nil)
        end
        format.html { ajax_refresh }
      else
        flash[:error] = "There was an error creating the transaction."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      if @transaction.authored_update(current_user, params[:transaction])
        flash[:notice] = "Successfully updated the transaction."
        format.json do
          render :json => @transaction.as_json(:root => nil, :methods => :descriptor)
        end
        format.html { redirect_to flow_transaction_path(@transaction) }
      else
        flash[:error] = "There was an error updating the transaction."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy
  end
end
