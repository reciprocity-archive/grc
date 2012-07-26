# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# HandleSystems
class SystemsController < ApplicationController
  include ApplicationHelper

  access_control :acl do
    allow :superuser, :admin, :analyst
  end

  layout 'dashboard'

  def edit
    @system = System.find(params[:id])

    render :layout => nil
  end

  def show
    @system = System.find(params[:id])
  end

  def tooltip
    @system = System.find(params[:id])
    render :layout => '_tooltip', :locals => { :system => @system }
  end

  def new
    @system = System.new(params[:system])

    render :layout => nil
  end

  def create
    if params[:system]
      params[:system][:infrastructure] = params[:system][:type] == 'infrastructure'
      params[:system].delete(:type)
    end

    @system = System.new(params[:system])

    respond_to do |format|
      if @system.save
        flash[:notice] = "Successfully created a new system."
        format.html { redirect_to flow_system_path(@system) }
      else
        flash[:error] = "There was an error creating the system"
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    if params[:system]
      params[:system][:infrastructure] = params[:system][:type] == 'infrastructure'
      params[:system].delete(:type)
    end

    @system = System.find(params[:id])

    respond_to do |format|
      if @system.authored_update(current_user, params[:system])
        flash[:notice] = "Successfully updated the system."
        format.html { redirect_to flow_system_path(@system) }
      else
        flash[:error] = "There was an error updating the system"
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def destroy
    @system = System.find(params[:id])

    respond_to do |format|
      if @system.destroy
        flash[:notice] = "System deleted"
        format.html { ajax_refresh }
      else
        flash[:error] = "Failed to delete system"
        format.html { ajax_refresh }
      end
    end
  end

  def index
    @systems = System.all
  end

  def subsystems_edit
    @system = System.find(params[:id])
    @systems = System.where({})
    render :layout => nil
  end

  def subsystems_update
    @system = System.find(params[:id])
    @system.sub_system_systems.clear

    params[:items].each do |_, item|
      # Do whatever is needed with item-forms
      subsystem = System.find(item[:id])
      # Don't allow adding self as a sub system
      if subsystem != @system
        @system.sub_system_systems << SystemSystem.new(:child => subsystem)
      end
    end

    @system.sub_systems.reload
    @system.sub_systems.include_root_in_json = false
    render :json => @system.sub_systems.all.map(&:as_json)
  end

  def controls_edit
    @system = System.find(params[:id])
    @controls = Control.where({})
    render :layout => nil
  end

  def controls_update
    @system = System.find(params[:id])
    @system.system_controls.clear

    params[:items].each do |_, item|
      # Do whatever is needed with item-forms
      control = Control.find(item[:id])
      @system.system_controls << SystemControl.new(:control => control)
    end

    @system.controls.reload
    @system.controls.include_root_in_json = false
    render :json => @system.controls.all.map(&:as_json)
  end
end
