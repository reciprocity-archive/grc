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
  end

  def index
    @controls = Control.all
  end
end
