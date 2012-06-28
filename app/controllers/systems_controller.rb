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
    render :layout => nil
  end

  def new
    @system = System.new

    render :layout => nil
  end

  def create
    @system = System.new(params[:system])

    respond_to do |format|
      if @system.save
        flash[:notice] = "Successfully created a new system."
        format.html { redirect_to flow_system_path(@system) }
      else
        flash[:error] = @system.errors.full_messages
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    @system = System.new(params[:id])

    respond_to do |format|
      if @system.authored_update(current_user, params[:system])
        flash[:notice] = "Successfully updated the system."
        format.html { redirect_to flow_system_path(@system) }
      else
        flash[:error] = @system.errors.full_messages
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def index
    @systems = System.all
  end
end
