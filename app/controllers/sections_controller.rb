# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Browse sections
class SectionsController < ApplicationController
  include ApplicationHelper
  include ProgramsHelper

  before_filter :load_section, :only => [:edit,
                                        :update,
                                        :tooltip]

  access_control :acl do
    allow :superuser, :admin, :analyst

    actions :new, :create do
      allow :create_section
    end

    actions :tooltip do
      allow :read_section, :of => :section
    end

    actions :edit, :update do
      allow :update_section, :of => :section
    end
  end

  layout 'dashboard'

  def tooltip
    render :layout => nil
  end

  def new
    @section = Section.new(section_params)

    render :layout => nil
  end

  def edit
    render :layout => nil
  end

  def create
    @section = Section.new(section_params)

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
    respond_to do |format|
      if @section.authored_update(current_user, section_params)
        flash[:notice] = "Successfully updated the section!"
        format.html { ajax_refresh }
      else
        flash[:error] = "There was an error updating the control"
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  private
    def load_section
      @section = Section.find(params[:id])
    end

    def section_params
      section_params = params[:section] || {}
      if section_params[:program_id]
        # TODO: Validate the user has access to add sections to the program
        section_params[:program] = Program.where(:id => section_params.delete(:program_id)).first
      end
      section_params
    end
end
