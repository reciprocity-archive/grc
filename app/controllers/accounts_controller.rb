# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class AccountsController < BaseObjectsController

#  access_control :acl do
#    allow :superuser
#
#    actions :new, :create do
#      allow :create, :create_account
#    end
#
#    actions :edit, :update do
#      allow :update, :update_account, :of => :account
#    end
#  end
  
  before_filter :check_admin_authorization

  layout 'dashboard'

  no_base_action :show, :tooltip

  private

    def update_object(account_params=nil)
      account_params = object_params
      role = account_params.delete(:role)
      object.role = role if role.present?

      super

      if params[:disable_password] == 'yes'
        object.disable_password!
      end
    end
end
