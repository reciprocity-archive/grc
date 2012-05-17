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
  end

  def update
  end

  def show
    @control = Control.find(params[:id])
  end

  def new
    @control = Control.new
  end

  def create
    @control = Control.new(params[:control])

    if @control.save
      redirect_to :back
    else
      flash[:error] = "This is an error"
      redirect_to :back
    end
  end

  def index
    @controls = Control.all
  end
end
