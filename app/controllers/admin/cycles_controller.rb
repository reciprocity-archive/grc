class Admin::CyclesController < ApplicationController
  layout "admin"

  # List cycles
  def index
    @cycles = Cycle.all

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

  # Edit doc form
  def edit
    @cycle = Cycle.get(params[:id])
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
