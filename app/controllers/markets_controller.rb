# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle markets
class MarketsController < ApplicationController
  include ApplicationHelper

  before_filter :load_market, :only => [:show,
                                         :edit,
                                         :update,
                                         :tooltip,
                                         :delete,
                                         :destroy]

  access_control :acl do
    # FIXME: Implement real authorization

    allow :superuser

    actions :new, :create do
      allow :create, :create_market
    end

    actions :edit, :update do
      allow :update, :update_market, :of => :market
    end

    actions :show, :tooltip do
      allow :read, :read_market, :of => :market
    end

  end

  layout 'dashboard'

  def index
    @markets = Market
    if params[:s]
      @markets = @markets.db_search(params[:s])
    end
    @markets = allowed_objs(@markets.all, :read)

    render :json => @markets
  end

  def show
  end

  def new
    @market = Market.new(market_params)
    render :layout => nil
  end

  def edit
    render :layout => nil
  end

  def create
    @market = Market.new(market_params)

    respond_to do |format|
      if @market.save
        flash[:notice] = "Successfully created a new org group."
        format.json { render :json => @market.as_json(:root => nil), :location => flow_market_path(@market) }
        format.html { redirect_to flow_market_path(@market) }
      else
        flash[:error] = "There was an error creating the org group."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    if !params[:market]
      return 400
    end

    respond_to do |format|
      if @market.authored_update(current_user, market_params)
        flash[:notice] = "Successfully updated the org group."
        format.json { render :json => @market.as_json(:root => nil), :location => flow_market_path(@market) }
        format.html { redirect_to flow_market_path(@market) }
      else
        flash[:error] = "There was an error updating the org group."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def delete
    @model_stats = []
    @relationship_stats = []

    # FIXME: Automatically generate relationship stats

    respond_to do |format|
      format.json { render :json => @market.as_json(:root => nil) }
      format.html do
        render :layout => nil, :template => 'shared/delete_confirm',
          :locals => { :model => @market, :url => flow_market_path(@market), :models => @model_stats, :relationships => @relationship_stats }
      end
    end
  end

  def destroy
    @market.destroy
    flash[:notice] = "market deleted"
    respond_to do |format|
      format.html { redirect_to programs_dash_path }
      format.json { render :json => @market.as_json(:root => nil), :location => programs_dash_path }
    end
  end

  def tooltip
    render :layout => '_tooltip', :locals => { :market => @market }
  end

  private

    def load_market
      @market = Market.find(params[:id])
    end

    def market_params
      market_params = params[:market] || {}
      %w(type).each do |field|
        parse_option_param(market_params, field)
      end
      market_params
    end
end
