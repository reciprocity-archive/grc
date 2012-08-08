class Admin::SectionsController < ApplicationController
  layout "admin"

  include ManyHelper
  include AutofilterHelper

  # List (possibly filtered) Control Objectives
  def index
    @sections = filtered_sections

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sections }
    end
  end

  # Show one CO
  def show
    @section = Section.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @section }
    end
  end

  # Show new CO form
  def new
    @section = Section.new
    # If we memorized a program, prefill relevant fields
    if session[:ui_program_id]
      begin
        @section.program = Program.find(session[:ui_program_id])
        @section.slug = @section.program.slug + "-"
      rescue
      end
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @section }
    end
  end

  # Show edit CO form
  def edit
    @section = Section.find(params[:id])
  end

  # Create CO
  def create
    # Memorize program for faster data entry
    session[:ui_program_id] = params[:section][:program_id]

    program = Program.find(params[:section].delete("program_id"))
    @section = Section.new(params[:section])
    @section.program = program

    respond_to do |format|
      if @section.save
        format.html { redirect_to(edit_section_path(@section), :notice => 'Section was successfully created.') }
        format.xml  { render :xml => @section, :status => :created, :location => @section }
      else
        flash.now[:error] = "Could not create."
        format.html { render :action => "new" }
        format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Update CO
  def update
    session[:ui_program_id] = params[:section][:program_id]
    @section = Section.find(params[:id])

    respond_to do |format|
      if @section.update_attributes(params[:section])
        format.html { redirect_to(edit_section_path(@section), :notice => 'Section was successfully updated.') }
        format.xml  { head :ok }
      else
        flash.now[:error] = "Could not update."
        format.html { render :action => "edit" }
        format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Delete CO
  def destroy
    section = Section.find(params[:id])
    section.destroy

    respond_to do |format|
      format.html { redirect_to(sections_url) }
      format.xml  { head :ok }
    end
  end

  # Get CO slug for AJAX
  def slug
    respond_to do |format|
      format.js { Section.find(params[:id]).slug }
    end
  end

  # Many2many editing of relationship to Controls
  def controls
    if request.put?
      post_many2many(:left_class => Section, :right_class => Control)
    else
      get_many2many(:left_class => Section, :right_class => Control)
    end
  end
end
