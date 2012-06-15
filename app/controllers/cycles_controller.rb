# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class CyclesController < ApplicationController

  layout 'dashboard'

  def show
    @cycle = Cycle.find(params[:id])
  end

  def create
    @cycle = Cycle.new(params[:cycle])

    respond_to do |format|
      if @cycle.save
        flash[:notice] = "Successfully created a new cycle"
        format.html { redirect_to flow_cycle_path(@cycle) }
      else
        flash[:error] = @cycle.errors.full_messages
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    @cycle = Cycle.find(params[:id])

    respond_to do |format|
      if @cycle.authored_update(current_user, params[:cycle])
        flash[:notice] = "Successfully updated the cycle!"
        format.html { redirect_to flow_cycle_path(@cycle) }
      else
        flash[:error] = @cycle.errors.full_messages
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end
end
