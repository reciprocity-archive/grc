class Admin::CyclesController < ApplicationController
  layout "admin"

  # List cycles
  def index
    @cycles = Cycle.all(:order => [:regulation_id, :start_at])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @cycles }
    end
  end

  # Show a doc
  def show
    @cycle = Cycle.get(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @cycle }
    end
  end

  # New doc form
  def new
    @cycle = Cycle.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @cycle }
    end
  end

  def new_clone
    @other_cycle = Cycle.get(params[:id])
    @cycle = Cycle.new
    @cycle.regulation = @other_cycle.regulation
    @cycle.start_at ||= @other_cycle.start_at

    respond_to do |format|
      format.html
      format.xml  { render :xml => @cycle }
    end
  end

  # Edit doc form
  def edit
    @cycle = Cycle.get(params[:id])
  end

  # Create a doc
  def clone
    @cycle = Cycle.new(params[:cycle])
    @other_cycle = Cycle.get(params[:id])
    @cycle.regulation = @other_cycle.regulation
    res = []
    res << @cycle.save
    if res.all?
      SystemControl.all(:cycle => @other_cycle).each do |sc|
        res << SystemControl.create(:control => sc.control, :system => sc.system, :cycle => @cycle)
      end
    end

    respond_to do |format|
      if res.all?
        format.html { redirect_to(edit_cycle_path(@cycle), :notice => 'Cycle was successfully created.') }
        format.xml  { render :xml => @cycle, :status => :created, :location => @cycle }
      elsif res[0]
        format.html { redirect_to(edit_cycle_path(@cycle), :error => 'Could not copy some System-Control connections.') }
        format.xml  { render :xml => @cycle.errors, :status => :unprocessable_entity }
      else
        flash.now[:error] = "Could not create."
        format.html { render :action => "new_clone" }
        format.xml  { render :xml => @cycle.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Create a doc
  def create
    @cycle = Cycle.new(params[:cycle])

    respond_to do |format|
      if @cycle.save
        format.html { redirect_to(edit_cycle_path(@cycle), :notice => 'Cycle was successfully created.') }
        format.xml  { render :xml => @cycle, :status => :created, :location => @cycle }
      else
        flash.now[:error] = "Could not create."
        format.html { render :action => "new" }
        format.xml  { render :xml => @cycle.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Update a doc
  def update
    @cycle = Cycle.get(params[:id])

    respond_to do |format|
      if @cycle.update(params[:cycle])
        format.html { redirect_to(edit_cycle_path(@cycle), :notice => 'Cycle was successfully updated.') }
        format.xml  { head :ok }
      else
        flash.now[:error] = "Could not update."
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cycle.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Delete a doc
  def destroy
    @cycle = Cycle.get(params[:id])
    @cycle.destroy

    respond_to do |format|
      format.html { redirect_to(cycles_url) }
      format.xml  { head :ok }
    end
  end
end
