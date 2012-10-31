# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Browse sections
class SectionsController < ApplicationController
  include ApplicationHelper
  include ProgramsHelper

  before_filter :load_section, :only => [:edit,
                                        :update,
                                        :delete,
                                        :destroy,
                                        :tooltip]

  access_control :acl do
    allow :superuser

    actions :new, :create do
      allow :create, :create_section
    end

    allow :read, :read_section, :of => :system, :to => [:show,
                                                        :tooltip]

    actions :edit, :update do
      allow :update, :update_section, :of => :section
    end
  end

  layout 'dashboard'

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

  def delete
    @model_stats = []
    @relationship_stats = []
    @relationship_stats << [ 'Control', @section.control_sections.count ]
    @relationship_stats << [ 'Document', @section.documents.count ]
    @relationship_stats << [ 'Category', @section.categories.count ]
    @relationship_stats << [ 'Person', @section.people.count ]
    respond_to do |format|
      format.json { render :json => @section.as_json(:root => nil) }
      format.html do
        render :layout => nil, :template => 'shared/delete_confirm',
          :locals => { :model => @section, :url => flow_section_path(@section), :models => @model_stats, :relationships => @relationship_stats }
      end
    end
  end

  def destroy
    @section.destroy
    flash[:notice] = "Section deleted"
    respond_to do |format|
      format.html { redirect_to flow_program_path(@section.program) }
      format.json { render :json => @section.as_json(:root => nil) }
    end
  end

  def tooltip
    render :layout => nil
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
