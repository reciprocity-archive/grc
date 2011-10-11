class Admin::SystemsController < ApplicationController
  layout "admin"
  include ManyHelper

  def index
    @systems = System.all

    respond_to do |format|
      format.html
      format.xml  { render :xml => @systems }
    end
  end

  def show
    @system = System.get(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @system }
    end
  end

  def new
    @system = System.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @system }
    end
  end

  def edit
    @system = System.get(params[:id])
  end

  def create
    @system = System.new(params[:system])

    respond_to do |format|
      if @system.save
        format.html { redirect_to(edit_system_path(@system), :notice => 'System was successfully created.') }
        format.xml  { render :xml => @system, :status => :created, :location => @system }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @system.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @system = System.get(params[:id])

    results = []
    params[:documents].each_pair do |index, doc_params|
      next if doc_params["link"].blank?
      is_delete = doc_params.delete("delete") == "1"
      id = doc_params.delete("id")
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
        if params[:system][:password]
          @system.crypted_password = nil
          @system.save
        end

        format.html { redirect_to(edit_system_path(@system), :notice => 'System was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @system.errors, :status => :unprocessable_entity }
      end
    end
  end

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

  def controls
    if request.put?
      post_many2many(:left_class => System, :right_class => Control)
    else
      get_many2many(:left_class => System, :right_class => Control)
    end
  end

  def control_objectives
    if request.put?
      post_many2many(:left_class => System, :right_class => ControlObjective)
    else
      get_many2many(:left_class => System, :right_class => ControlObjective)
    end
  end

  def biz_processes
    if request.put?
      post_many2many(:left_class => System, :right_class => BizProcess)
    else
      get_many2many(:left_class => System, :right_class => BizProcess)
    end
  end
end
