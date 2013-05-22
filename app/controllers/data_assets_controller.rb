# Handle markets
class DataAssetsController < BusinessObjectsController

#  access_control :acl do
#    # FIXME: Implement real authorization
#
#    allow :superuser
#
#    actions :new, :create do
#      allow :create, :create_data_asset
#    end
#
#    actions :edit, :update do
#      allow :update, :update_data_asset, :of => :data_asset
#    end
#
#    actions :show, :tooltip do
#      allow :read, :read_data_asset, :of => :data_asset
#    end
#
#  end

  layout 'dashboard'

  private

    def data_asset_params
      data_asset_params = params[:data_asset] || {}
      %w(type).each do |field|
        parse_option_param(data_asset_params, field)
      end
      %w(start_date stop_date).each do |field|
        parse_date_param(data_asset_params, field)
      end
      data_asset_params
    end
end
