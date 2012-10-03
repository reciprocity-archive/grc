# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle Transactions
class TransactionsController < ApplicationController
  before_filter :load_transaction, :only => [:edit,
                                       :update,
                                       :delete,
                                       :destroy]
  include ApplicationHelper

  access_control :acl do
    allow :superuser
  end

  layout 'dashboard'

  def new
    @transaction = Transaction.new(transaction_params)
    render :layout => nil
  end

  def edit
    render :layout => nil
  end

  def create
    @transaction = Transaction.new(transaction_params)

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
    respond_to do |format|
      if @transaction.authored_update(current_user, transaction_params)
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

  def delete
    @model_stats = []
    @relationship_stats = []
    respond_to do |format|
      format.json { render :json => @transaction.as_json(:root => nil) }
      format.html do
        render :layout => nil, :template => 'shared/delete_confirm',
          :locals => { :model => @transaction, :url => flow_transaction_path(@transaction), :models => @model_stats, :relationships => @relationship_stats }
      end
    end
  end

  def destroy
    @transaction.destroy
    flash[:notice] = "Transaction deleted"
    respond_to do |format|
      format.html { redirect_to flow_system_path(@transaction.system) }
      format.json { render :json => @transaction.as_json(:root => nil) }
    end
  end

  private
    def load_transaction
      @transaction = Transaction.find(params[:id])
    end

    def transaction_params
      transaction_params = params[:transaction] || {}
      if transaction_params[:system_id]
        # TODO: Validate the user has access to add transactions to the system
        transaction_params[:system] = System.where(:id => transaction_params.delete(:system_id)).first
      end
      transaction_params
    end
end
