# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Browse sections
class SectionsController < ApplicationController
  include ApplicationHelper
  include ProgramsHelper

  access_control :acl do
    allow :superuser, :admin, :analyst
  end

  layout 'dashboard'

  def tooltip
    @section = Section.find(params[:id])
    render :layout => nil
  end

  def new
    @section = Section.new(params[:section])

    render :layout => nil
  end

  def edit
    @section = Section.find(params[:id])

    render :layout => nil
  end

  def create
    @section = Section.new(params[:section])

    respond_to do |format|
      if @section.save
        flash[:notice] = "Successfully created a new section"
        format.html { ajax_refresh }
      else
        flash[:error] = "There was an error creating the section."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    @section = Section.find(params[:id])

    respond_to do |format|
      if @section.authored_update(current_user, params[:section] || {})
        flash[:notice] = "Successfully updated the section!"
        format.html { ajax_refresh }
      else
        flash[:error] = "There was an error updating the control"
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end
end
