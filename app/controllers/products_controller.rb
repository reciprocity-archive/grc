# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle Products
class ProductsController < ApplicationController
  include ApplicationHelper

  before_filter :load_product, :only => [:show,
                                         :edit,
                                         :update,
                                         :tooltip]

  access_control :acl do
    # FIXME: Implement real authorization

    allow :superuser

    actions :index do
      allow :read, :read_product
    end

    actions :new, :create do
      allow :create, :create_product
    end

    actions :edit, :update do
      allow :update, :update_product, :of => :product
    end

    actions :show, :tooltip do
      allow :read, :read_product, :of => :product
    end

  end

  layout 'dashboard'

  def show
  end

  def new
    @product = Product.new(params[:product])
    render :layout => nil
  end

  def edit
    render :layout => nil
  end

  def create
    @product = Product.new(params[:product])

    respond_to do |format|
      if @product.save
        flash[:notice] = "Successfully created a new product."
        format.html { redirect_to flow_product_path(@product) }
      else
        flash[:error] = "There was an error creating the product."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    if !params[:product]
      return 400
    end

    respond_to do |format|
      if @product.authored_update(current_user, params[:product])
        flash[:notice] = "Successfully updated the product."
        format.html { redirect_to flow_product_path(@product) }
      else
        flash[:error] = "There was an error updating the product."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def tooltip
    render :layout => '_tooltip', :locals => { :product => @product }
  end

  private

    def load_product
      @product = Product.find(params[:id])
    end

    def product_params
      product_params = params[:product] || {}
      %w(type).each do |field|
        parse_option_param(program_params, field)
      end
      product_params
    end
end
