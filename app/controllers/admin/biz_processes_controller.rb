class Admin::BizProcessesController < ApplicationController
  layout "admin"
  include Admin::BizProcessesHelper

  def index
    @biz_processes = BizProcess.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @biz_processes }
    end
  end

  def show
    @biz_process = BizProcess.get(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @biz_process }
    end
  end

  def new
    @biz_process = BizProcess.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @biz_process }
    end
  end

  def edit
    @biz_process = BizProcess.get(params[:id])
  end

  def create
    @biz_process = BizProcess.new

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

  def update
    @biz_process = BizProcess.get(params[:id])

    results = []
    update_biz_process_relations(@biz_process, params[:biz_process])

    (params[:policies] || {}).each_pair do |index, doc_params|
      next if doc_params["link"].blank?
      is_delete = doc_params.delete("delete") == "1"
      id = doc_params.delete("id")
      if id.blank?
        doc = @biz_process.policies.create(doc_params)
        results << doc
      elsif is_delete
        results << @biz_process.biz_process_documents.first(:policy_id => id).destroy
        results << Document.first(:id => id).destroy
      else
        results << Document.get(id).update(doc_params)
      end
    end

    @biz_process.save if @biz_process.dirty?

    results << @biz_process.update(params[:biz_process])

    respond_to do |format|
      if results.all?
        format.html { redirect_to(edit_biz_process_path(@biz_process), :notice => 'Biz Process was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @biz_process.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    biz_process = BizProcess.get(params[:id])

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

  def controls
    if request.post?
      post_many2many(:left_class => BizProcess,
                     :right_class => Control,
                     :lefts => filtered_control_objectives)
    else
      content_for :secnav, partial("biz_processes/secnav")
      get_many2many(:left_class => BizProcess, :right_class => Control)
    end
  end

  def systems
    if request.post?
      post_many2many(:left_class => BizProcess, :right_class => System)
    else
      content_for :secnav, partial("biz_processes/secnav")
      get_many2many(:left_class => BizProcess, :right_class => System)
    end
  end
end
