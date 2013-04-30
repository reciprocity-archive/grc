# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle markets
class MarketsController < BusinessObjectsController

#  access_control :acl do
#    # FIXME: Implement real authorization
#
#    allow :superuser
#
#    actions :new, :create do
#      allow :create, :create_market
#    end
#
#    actions :edit, :update do
#      allow :update, :update_market, :of => :market
#    end
#
#    actions :show, :tooltip do
#      allow :read, :read_market, :of => :market
#    end
#
#  end

  layout 'dashboard'

  private

    def market_params
      market_params = params[:market] || {}
      %w(type).each do |field|
        parse_option_param(market_params, field)
      end
      %w(start_date stop_date).each do |field|
        parse_date_param(market_params, field)
      end
      market_params
    end
end
