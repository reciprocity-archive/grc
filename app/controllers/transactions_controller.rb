# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle Transactions
class TransactionsController < BaseObjectsController

#  access_control :acl do
#    allow :superuser
#  end

  layout 'dashboard'

  no_base_action :index, :show, :tooltip

  private

    def object_path
      flow_system_path(@transaction.system)
    end

    def post_destroy_path
      flow_system_path(@transaction.system)
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
