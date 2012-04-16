class Admin::BusinessAreasController < ApplicationController
  layout "admin"

  # List of biz areas
  def index
    @business_areas = BusinessArea.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @business_areas }
    end
  end

  # Show a biz area
  def show
    @business_area = BusinessArea.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @business_area }
    end
  end

  # New biz area form
  def new
    @business_area = BusinessArea.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @business_area }
    end
  end

  # Edit biz area form
  def edit
    @business_area = BusinessArea.find(params[:id])
  end

  # Create a biz area
  def create
    @business_area = BusinessArea.new(params[:business_area])

    respond_to do |format|
      if @business_area.save
        format.html { redirect_to(edit_business_area_path(@business_area), :notice => 'Biz Process was successfully created.') }
        format.xml  { render :xml => @business_area, :status => :created, :location => @business_area }
      else
        flash.now[:error] = "Could not create."
        format.html { render :action => "new" }
        format.xml  { render :xml => @business_area.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Update a biz area
  def update
    @business_area = BusinessArea.find(params[:id])

    respond_to do |format|
      if @business_area.update_attributes(params[:business_area])
        format.html { redirect_to(edit_business_area_path(@business_area), :notice => 'Biz Process was successfully updated.') }
        format.xml  { head :ok }
      else
        flash.now[:error] = "Could not update."
        format.html { render :action => "edit" }
        format.xml  { render :xml => @business_area.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Delete a biz area
  def destroy
    business_area = BusinessArea.find(params[:id])

    respond_to do |format|
      format.html { redirect_to(business_areas_url) }
      format.xml  { head :ok }
    end
  end

end
