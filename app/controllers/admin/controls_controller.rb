class Admin::ControlsController < ApplicationController
  layout "admin"

  include ManyHelper
  include AutofilterHelper

  # List Controls
  def index
    @controls = filtered_controls

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @controls }
    end
  end

  # Show a Control
  def show
    @control = Control.get(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @control }
    end
  end

  # New control form
  def new
    @control = Control.new
    @control.effective_at = Date.today

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @control }
    end
  end

  # Edit control form
  def edit
    @control = Control.get(params[:id])
  end

  # Create a control
  def create
    @control = Control.new(params[:control])

    respond_to do |format|
      if @control.save
        format.html { redirect_to(edit_control_path(@control), :notice => 'Control was successfully created.') }
        format.xml  { render :xml => @control, :status => :created, :location => @control }
      else
        flash.now[:error] = "Could not create."
        format.html { render :action => "new" }
        format.xml  { render :xml => @control.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Update a control
  def update
    @control = Control.get(params[:id])

    # Connect to related Control Objectives
    co_ids = params["control"].delete("co_ids") || []

    if !equal_ids(co_ids, @control.control_objectives)
      @control.control_objectives = []
      co_ids.each do |co_id|
        co = ControlObjective.get(co_id)
        @control.control_objectives << co
      end
    end

    respond_to do |format|
      res = @control.save
      if res && @control.authored_update(current_user, params["control"])
        format.html { redirect_to(edit_control_path(@control), :notice => 'Control was successfully updated.') }
        format.xml  { head :ok }
      else
        flash.now[:error] = "Could not update."
        format.html { render :action => "edit" }
        format.xml  { render :xml => @control.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Delete a control
  def destroy
    control = Control.get(params[:id])
    success = control && control.biz_process_controls.destroy &&
        control.system_controls.destroy &&
        control.control_document_descriptors.destroy &&
        control.destroy

    respond_to do |format|
      format.html { redirect_to(controls_url) }
      format.xml  { head :ok }
    end
  end

  # Slug for AJAX
  def slug
    respond_to do |format|
      format.js { Control.get(params[:id]).slug }
    end
  end

  # Many2many relationship to Systems
  def systems
    lefts = filtered_controls.all_company
    if lefts.empty?
      flash[:error] = 'No company controls'
      redirect_to controls_path
      return
    end
    if request.put?
      raise "cannot save without cycle" unless @cycle
      control = Control.get(params[:id])
      ids = params[:control]["system_ids"]
      control.system_controls.each do |sc|
        if sc.cycle == @cycle && !ids.include?(sc.system_id)
          ids.delete(sc.system_id)
          sc.authored_destroy(current_user)
        end
      end
      ids.each do |id|
        res = control.system_controls.create(:system => System.get(id), :cycle => @cycle, :modified_by => current_user)
        # FIXME why is this necessary?
        res.save!
      end
      # FIXME
      control.reload
    else
      if params[:id]
        control = Control.get(params[:id])
      else
        control = lefts.first
      end
    end
    if @cycle
      @left_nested = control.system_controls_for_cycle(@cycle)
    end
    get_many2many(:left_class => Control,
                  :right_class => System,
                  :lefts => lefts,
                  :show_slugfilter => true,
                 )
  end

  # Many2many relationship to Control Objectives
  def control_objectives
    if request.put?
      post_many2many(:left_class => Control,
                     :right_class => ControlObjective,
                     :lefts => filtered_controls)
    else
      get_many2many(:left_class => Control,
                    :right_class => ControlObjective,
                    :lefts => filtered_controls,
                    :show_slugfilter => true)
    end
  end

  # Many2many relationship to Biz Processes
  def biz_processes
    if request.put?
      post_many2many(:left_class => Control,
                     :right_class => BizProcess,
                     :lefts => filtered_controls.all_company)
    else
      get_many2many(:left_class => Control,
                    :right_class => BizProcess,
                    :lefts => filtered_controls.all_company,
                    :show_slugfilter => true)
    end
  end

  # Many2many relationship to self (which controls implement other controls)
  def controls
    if request.put?
      post_many2many(:left_class => Control,
                     :right_class => Control,
                     :right_relation => :implemented_controls,
                     :right_ids => :implemented_control_ids,
                     :lefts => filtered_controls.all_company)
    else
      get_many2many(:left_class => Control,
                    :lefts => filtered_controls.all_company,
                    :right_class => Control,
                    :right_ids => :implemented_control_ids,
                    :show_slugfilter => true)
    end
  end

  # Many2many relationship to Document Descriptors (describing what evidence can be attached)
  def evidence_descriptors
    if request.put?
      post_many2many(:left_class => Control,
                     :right_class => DocumentDescriptor,
                     :right_relation => :evidence_descriptors,
                     :right_ids => :evidence_descriptor_ids,
                     :lefts => filtered_controls.all_company)
    else
      get_many2many(:left_class => Control,
                    :lefts => filtered_controls.all_company,
                    :right_class => DocumentDescriptor,
                    :right_ids => :evidence_descriptor_ids,
                    :show_slugfilter => true)
    end
  end

  # Another way to attach a biz process
  def add_biz_process
    @control = Control.get(params[:id])
  end
 
  # Another way to attach a biz process
  def create_biz_process
    @control = Control.get(params[:id])
    @biz_process_control = BizProcessControl.new(params[:biz_process_control])
    @biz_process_control.control = @control
    if @biz_process_control.save
      flash[:notice] = 'Biz Process was successfully attached.'
      redirect_to edit_control_path(@biz_process_control.control)
    else
      redirect_to add_biz_process_control_path(@biz_process_control.control)
    end
  end
 
  # Another way to detach a biz process
  def destroy_biz_process
    bpc = BizProcessControl.first(:control_id => params[:id], :biz_process_id => params[:biz_process_id])
    if bpc.destroy
      flash[:notice] = 'Biz Process was successfully detached.'
    else
      flash[:error] = 'Failed'
    end
    redirect_to edit_control_path(bpc.control)
  end
 
  # Another way to detach an implemented control
  def destroy_implemented_control
    cc = ControlControl.first(:control_id => params[:id], :implemented_control_id => params[:implemented_control_id])
    if cc && cc.destroy
      flash[:notice] = 'Control was successfully detached.'
    else
      flash[:error] = 'Failed'
    end
    redirect_to edit_control_path(Control.get(params[:id]))
  end

  def implement
    unless @company
      flash[:error] = 'Must set a company first.'
      redirect_to controls_path
      return
    end
    @origin = Control.get(params[:id])

    @control = Control.new
    @control.regulation = @company
    @control.slug = "#{@company.slug}-#{@origin.slug}"
    @control.implemented_controls << @origin
    @control.title = @origin.title
    @control.is_key = @origin.is_key
    @control.frequency = @origin.frequency
    @control.frequency_type = @origin.frequency_type
    @control.fraud_related = @origin.fraud_related
    @control.technical = @origin.technical
    @control.assertion = @origin.assertion
    @control.effective_at = @origin.effective_at
    @control.business_area = @origin.business_area
    
    respond_to do |format|
      if @control.save
        format.html { redirect_to(edit_control_path(@control), :notice => 'Control was successfully created.') }
        format.xml  { render :xml => @control, :status => :created, :location => @control }
      else
        flash.now[:error] = "Could not create."
        format.html { redirect_to controls_path }
        format.xml  { render :xml => @control.errors, :status => :unprocessable_entity }
      end
    end
  end
end
