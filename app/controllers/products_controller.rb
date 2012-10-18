# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle Products
class ProductsController < ApplicationController
  include ApplicationHelper

  before_filter :load_product, :only => [:show,
                                         :edit,
                                         :update,
                                         :tooltip,
                                         :delete,
                                         :destroy]

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

  def index
    @products = Product
    if params[:s]
      @products = @products.db_search(params[:s])
    end
    @products = allowed_objs(@products.all, :read)

    render :json => @products
  end

  def show
  end

  def new
    @product = Product.new(product_params)
    render :layout => nil
  end

  def edit
    render :layout => nil
  end

  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        flash[:notice] = "Successfully created a new product."
        format.json { render :json => @product.as_json(:root => nil), :location => flow_product_path(@product) }
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
      if @product.authored_update(current_user, product_params)
        flash[:notice] = "Successfully updated the product."
        format.json { render :json => @product.as_json(:root => nil), :location => flow_product_path(@product) }
        format.html { redirect_to flow_product_path(@product) }
      else
        flash[:error] = "There was an error updating the product."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def delete
    @model_stats = []
    @relationship_stats = []

    # FIXME: Automatically generate relationship stats

    respond_to do |format|
      format.json { render :json => @product.as_json(:root => nil) }
      format.html do
        render :layout => nil, :template => 'shared/delete_confirm',
          :locals => { :model => @product, :url => flow_product_path(@product), :models => @model_stats, :relationships => @relationship_stats }
      end
    end
  end

  def destroy
    @product.destroy
    flash[:notice] = "Product deleted"
    respond_to do |format|
      format.html { redirect_to programs_dash_path }
      format.json { render :json => product.as_json(:root => nil) }
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
        parse_option_param(product_params, field)
      end
      %w(start_date stop_date).each do |field|
        parse_date_param(product_params, field)
      end
      product_params
    end
end
