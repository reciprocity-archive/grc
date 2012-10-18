# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle locations
class LocationsController < ApplicationController
  include ApplicationHelper

  before_filter :load_location, :only => [:show,
                                         :edit,
                                         :update,
                                         :tooltip,
                                         :delete,
                                         :destroy]

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

  def index
    @locations = Location
    if params[:s]
      @locations = @locations.db_search(params[:s])
    end
    @locations = allowed_objs(@locations.all, :read)

    render :json => @locations
  end

  def show
  end

  def new
    @location = Location.new(location_params)
    render :layout => nil
  end

  def edit
    render :layout => nil
  end

  def create
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        flash[:notice] = "Successfully created a new org group."
        format.json { render :json => @location.as_json(:root => nil), :location => flow_location_path(@location)  }
        format.html { redirect_to flow_location_path(@location) }
      else
        flash[:error] = "There was an error creating the org group."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    if !params[:location]
      return 400
    end

    respond_to do |format|
      if @location.authored_update(current_user, location_params)
        flash[:notice] = "Successfully updated the org group."
        format.json { render :json => @location.as_json(:root => nil), :location => flow_location_path(@location) }
        format.html { redirect_to flow_location_path(@location) }
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
      format.json { render :json => @location.as_json(:root => nil) }
      format.html do
        render :layout => nil, :template => 'shared/delete_confirm',
          :locals => { :model => @location, :url => flow_location_path(@location), :models => @model_stats, :relationships => @relationship_stats }
      end
    end
  end

  def destroy
    @location.destroy
    flash[:notice] = "location deleted"
    respond_to do |format|
      format.html { redirect_to programs_dash_path }
      format.json { render :json => location.as_json(:root => nil) }
    end
  end

  def tooltip
    render :layout => '_tooltip', :locals => { :location => @location }
  end

  private

    def load_location
      @location = Location.find(params[:id])
    end

    def location_params
      location_params = params[:location] || {}
      %w(type).each do |field|
        parse_option_param(location_params, field)
      end
      location_params
    end
end
