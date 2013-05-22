# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle Products
class ProductsController < BusinessObjectsController

#  access_control :acl do
#    # FIXME: Implement real authorization
#
#    allow :superuser
#
#    actions :index do
#      allow :read, :read_product
#    end
#
#    actions :new, :create do
#      allow :create, :create_product
#    end
#
#    actions :edit, :update do
#      allow :update, :update_product, :of => :product
#    end
#
#    actions :show, :tooltip do
#      allow :read, :read_product, :of => :product
#    end
#
#  end

  layout 'dashboard'

  private

    def product_params
      product_params = params[:product] || {}
      %w(type).each do |field|
        parse_option_param(product_params, field)
      end
      %w(start_date stop_date).each do |field|
        parse_date_param(product_params, field)
      end
      product_params
    end
end
