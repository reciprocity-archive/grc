class Admin::SystemsController < ApplicationController
  layout "admin"
  include ManyHelper

  # List Systems
  def index
    @systems = System.all

    respond_to do |format|
      format.html
      format.xml  { render :xml => @systems }
    end
  end

  # Show a system
  def show
    @system = System.get(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @system }
    end
  end

  # New system form
  def new
    @system = System.new

    # A couple of lines for new docs
    @system.documents << Document.new
    @system.documents << Document.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @system }
    end
  end

  # Edit system form
  def edit
    @system = System.get(params[:id])

    # A couple of lines for new docs
    @system.documents << Document.new
    @system.documents << Document.new
  end

  # Create a system
  def create
    documents_params = params[:system].delete("document")
    @system = System.new(params[:system])

    # Accumulate results
    results = []
    documents_params.each_pair do |index, doc_params|
      next if doc_params["link"].blank?
      # Create / delete / update attached doc
      # TODO: find existing doc, gdoc integration
      doc = @system.documents.create(doc_params)
      results << doc
    end

    results << @system.save

    respond_to do |format|
      if results.all?
        format.html { redirect_to(edit_system_path(@system), :notice => 'System was successfully created.') }
        format.xml  { render :xml => @system, :status => :created, :location => @system }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @system.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Update a system
  def update
    @system = System.get(params[:id])

    # Accumulate results
    results = []
    documents_params = params[:system].delete("document")
    documents_params.each_pair do |index, doc_params|
      next if doc_params["link"].blank?
      is_delete = doc_params.delete("delete") == "1"
      id = doc_params.delete("id")
      # Create / delete / update attached doc
      if id.blank?
        doc = @system.documents.create(doc_params)
        results << doc
      elsif is_delete
        results << @system.document_systems.first(:document_id => id).destroy
        results << Document.first(:id => id).destroy
      else
        results << Document.get(id).update(doc_params)
      end
    end

    results << @system.update(params[:system])

    respond_to do |format|
      if results.all?
        format.html { redirect_to(edit_system_path(@system), :notice => 'System was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @system.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Delete a system
  def destroy
    system = System.get(params[:id])

    success = system.document_systems.destroy &&
        system.system_controls.destroy &&
        system.biz_process_systems.destroy &&
        system.system_control_objectives.destroy &&
        system.destroy

    respond_to do |format|
      format.html { redirect_to(systems_url) }
      format.xml  { head :ok }
    end
  end

  # Many2many relationship to Controls
  def controls
    if request.put?
      post_many2many(:left_class => System, :right_class => Control)
    else
      get_many2many(:left_class => System, :right_class => Control)
    end
  end

  # Many2many relationship to COs
  def control_objectives
    if request.put?
      post_many2many(:left_class => System, :right_class => ControlObjective)
    else
      get_many2many(:left_class => System, :right_class => ControlObjective)
    end
  end

  # Many2many relationship to Biz Processes
  def biz_processes
    if request.put?
      post_many2many(:left_class => System, :right_class => BizProcess)
    else
      get_many2many(:left_class => System, :right_class => BizProcess)
    end
  end
end
