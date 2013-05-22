# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle facilities
class FacilitiesController < BusinessObjectsController

#  access_control :acl do
#    # FIXME: Implement real authorization
#
#    allow :superuser
#
#    actions :new, :create do
#      allow :create, :create_facility
#    end
#
#    actions :edit, :update do
#      allow :update, :update_facility, :of => :facility
#    end
#
#    actions :show, :tooltip do
#      allow :read, :read_facility, :of => :facility
#    end
#
#  end

  layout 'dashboard'

  private

    def facility_params
      facility_params = params[:facility] || {}
      %w(type).each do |field|
        parse_option_param(facility_params, field)
      end
      %w(start_date stop_date).each do |field|
        parse_date_param(facility_params, field)
      end
      facility_params
    end
end
