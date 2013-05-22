# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle Org Groups
class OrgGroupsController < BusinessObjectsController

#  access_control :acl do
#    # FIXME: Implement real authorization
#
#    allow :superuser
#
#    actions :index do
#      allow :read, :read_org_group
#    end
#
#    actions :new, :create do
#      allow :create, :create_org_group
#    end
#
#    actions :edit, :update do
#      allow :update, :update_org_group, :of => :org_group
#    end
#
#    actions :show, :tooltip do
#      allow :read, :read_org_group, :of => :org_group
#    end
#
#  end

  layout 'dashboard'

  private

    def org_group_params
      org_group_params = params[:org_group] || {}
      %w(type).each do |field|
        parse_option_param(org_group_params, field)
      end
      %w(start_date stop_date).each do |field|
        parse_date_param(org_group_params, field)
      end
      org_group_params
    end
end
