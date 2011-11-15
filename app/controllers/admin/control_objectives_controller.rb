class Admin::ControlObjectivesController < ApplicationController
  layout "admin"

  include ManyHelper
  include AutofilterHelper

  # List (possibly filtered) Control Objectives
  def index
    @control_objectives = filtered_control_objectives

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @control_objectives }
    end
  end

  # Show one CO
  def show
    @control_objective = ControlObjective.get(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @control_objective }
    end
  end

  # Show new CO form
  def new
    @control_objective = ControlObjective.new
    # If we memorized a regulation, prefill relevant fields
    if session[:ui_regulation_id]
      begin
        @control_objective.regulation_id = session[:ui_regulation_id]
        @control_objective.slug = Regulation.get(session[:ui_regulation_id]).slug
      rescue
      end
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @control_objective }
    end
  end

  # Show edit CO form
  def edit
    @control_objective = ControlObjective.get(params[:id])
  end

  # Create CO
  def create
    # Memorize regulation for faster data entry
    session[:ui_regulation_id] = params[:control_objective][:regulation_id]

    @control_objective = ControlObjective.new(params[:control_objective])

    respond_to do |format|
      if @control_objective.save
        format.html { redirect_to(edit_control_objective_path(@control_objective), :notice => 'Control Objective was successfully created.') }
        format.xml  { render :xml => @control_objective, :status => :created, :location => @control_objective }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @control_objective.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Update CO
  def update
    session[:ui_regulation_id] = params[:control_objective][:regulation_id]
    @control_objective = ControlObjective.get(params[:id])

    respond_to do |format|
      if @control_objective.update(params[:control_objective])
        format.html { redirect_to(edit_control_objective_path(@control_objective), :notice => 'Control Objective was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @control_objective.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Delete CO
  def destroy
    control_objective = ControlObjective.get(params[:id])
    control_objective.destroy

    respond_to do |format|
      format.html { redirect_to(control_objectives_url) }
      format.xml  { head :ok }
    end
  end

  # Get CO slug for AJAX
  def slug
    respond_to do |format|
      format.js { ControlObjective.get(params[:id]).slug }
    end
  end

  # Many2many editing of relationship to Controls
  def controls
    if request.put?
      post_many2many(:left_class => ControlObjective, :right_class => Control)
    else
      get_many2many(:left_class => ControlObjective, :right_class => Control)
    end
  end
end
