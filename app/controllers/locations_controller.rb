# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle locations
class LocationsController < BusinessObjectsController

  access_control :acl do
    # FIXME: Implement real authorization

    allow :superuser

    actions :new, :create do
      allow :create, :create_location
    end

    actions :edit, :update do
      allow :update, :update_location, :of => :location
    end

    actions :show, :tooltip do
      allow :read, :read_location, :of => :location
    end

  end

  layout 'dashboard'

  private

    def location_params
      location_params = params[:location] || {}
      %w(type).each do |field|
        parse_option_param(location_params, field)
      end
      %w(start_date stop_date).each do |field|
        parse_date_param(location_params, field)
      end
      location_params
    end
end
