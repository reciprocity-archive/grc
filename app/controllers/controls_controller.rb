# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle Controls
class ControlsController < ApplicationController
  include ApplicationHelper
  include ControlsHelper

  access_control :acl do
    allow :superuser, :admin, :analyst
  end

  layout 'dashboard'

  def edit
    @control = Control.find(params[:id])

    render :layout => nil
  end

  def show
    @control = Control.find(params[:id])
  end

  def tooltip
    @control = Control.find(params[:id])
    render :layout => nil
  end

  def new
    @control = Control.new(params[:control])

    render :layout => nil
  end

  def create
    @control = Control.new(params[:control])

    respond_to do |format|
      if @control.save
        flash[:notice] = "Successfully created a new control"
        format.json do
          render :json => @control.as_json(:root => nil)
        end
        format.html { redirect_to flow_control_path(@control) }
      else
        flash[:error] = "There was an error creating the control."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    @control = Control.find(params[:id])

    respond_to do |format|
      if @control.authored_update(current_user, params[:control] || {})
        flash[:notice] = "Successfully updated the control!"
        format.json do
          render :json => @control.as_json(:root => nil)
        end
        format.html { redirect_to flow_control_path(@control) }
      else
        flash[:error] = "There was an error updating the control"
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def index
    @controls = Control.all
  end

  def sections
    @control = Control.find(params[:id])
    @sections =
      @control.sections.all +
      @control.implemented_controls.includes(:sections).map(&:sections).flatten
    @sections.sort_by(&:slug_split_for_sort)
    render :layout => nil, :locals => { :sections => @sections }
  end

  def implemented_controls
    @control = Control.find(params[:id])
    @controls = @control.implemented_controls
    if params[:s]
      @controls = @controls.search(params[:s])
    end
    @controls.all.sort_by(&:slug_split_for_sort)
    render :action => 'controls', :layout => nil, :locals => { :controls => @controls }
  end

  def implementing_controls
    @control = Control.find(params[:id])
    @controls = @control.implementing_controls
    if params[:s]
      @controls = @controls.search(params[:s])
    end
    @controls.all.sort_by(&:slug_split_for_sort)
    render :action => 'controls', :layout => nil, :locals => { :controls => @controls }
  end
end
