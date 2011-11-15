class Admin::BizProcessesController < ApplicationController
  layout "admin"
  include Admin::BizProcessesHelper
  include ManyHelper
  include AutofilterHelper

  # List all biz processes
  def index
    @biz_processes = BizProcess.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @biz_processes }
    end
  end

  # Show one biz process
  def show
    @biz_process = BizProcess.get(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @biz_process }
    end
  end

  # Show new biz process form 
  def new
    @biz_process = BizProcess.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @biz_process }
    end
  end

  # Show edit biz process form
  def edit
    @biz_process = BizProcess.get(params[:id])
  end

  # Create a biz process
  def create
    @biz_process = BizProcess.new

    # Attach biz process to any related objects specified by the user (Controls, COs, Systems)
    update_biz_process_relations(@biz_process, params[:biz_process])

    @biz_process.attributes = params[:biz_process]

    respond_to do |format|
      if @biz_process.save
        format.html { redirect_to(edit_biz_process_path(@biz_process), :notice => 'Biz Process was successfully created.') }
        format.xml  { render :xml => @biz_process, :status => :created, :location => @biz_process }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @biz_process.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Update a biz process
  def update
    @biz_process = BizProcess.get(params[:id])

    # Accumulate DB update results
    results = []

    # Attach biz process to any related objects specified by the user (Controls, COs, Systems)
    update_biz_process_relations(@biz_process, params[:biz_process])

    # Update linked policy documents
    (params[:policies] || {}).each_pair do |index, doc_params|
      next if doc_params["link"].blank?
      is_delete = doc_params.delete("delete") == "1"
      id = doc_params.delete("id")
      if id.blank?
        # No existing doc id - create the doc
        doc = @biz_process.policies.create(doc_params)
        results << doc
      elsif is_delete
        # Delete checkbox was on
        results << @biz_process.biz_process_documents.first(:policy_id => id).destroy
        results << Document.first(:id => id).destroy
      else
        # Otherwise, update
        results << Document.get(id).update(doc_params)
      end
    end

    # Save if any changes made above
    @biz_process.save if @biz_process.dirty?

    results << @biz_process.update(params[:biz_process])

    respond_to do |format|
      # If all operations above succeeded, show overall success, otherwise show errors
      if results.all?
        format.html { redirect_to(edit_biz_process_path(@biz_process), :notice => 'Biz Process was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @biz_process.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Delete biz process
  def destroy
    biz_process = BizProcess.get(params[:id])

    # Delete links to other objects first, then delete the biz process
    success = biz_process && biz_process.biz_process_systems.destroy &&
        biz_process.biz_process_controls.destroy &&
        biz_process.biz_process_control_objectives.destroy &&
        biz_process.biz_process_documents.destroy &&
        biz_process.destroy

    respond_to do |format|
      format.html { redirect_to(biz_processes_url) }
      format.xml  { head :ok }
    end
  end

  # Many2many relationship to Controls - show / update
  def controls
    if request.put?
      post_many2many(:left_class => BizProcess, :right_class => Control)
    else
      get_many2many(:left_class => BizProcess, :right_class => Control)
    end
  end

  # Many2many relationship to Systems - show / update
  def systems
    if request.put?
      post_many2many(:left_class => BizProcess, :right_class => System)
    else
      get_many2many(:left_class => BizProcess, :right_class => System)
    end
  end
end
