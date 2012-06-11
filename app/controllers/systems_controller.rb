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
  end

  def update
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
  end

  def create
    @system = System.new(params[:system])

    if @system.save
      redirect_to :back
    else
      flash[:error] = "This is an error"
      redirect_to :back
    end
  end

  def index
    @systems = System.all
  end
end
