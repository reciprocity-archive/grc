class Admin::PeopleController < ApplicationController
  layout "admin"

  # List People
  def index
    @people = Person.all

    respond_to do |format|
      format.html
      format.xml  { render :xml => @people }
    end
  end

  # Show a person
  def show
    @person = Person.get(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @person }
    end
  end

  # New person form
  def new
    @person = Person.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @person }
    end
  end

  # Edit person form
  def edit
    @person = Person.get(params[:id])
  end

  # Create a person
  def create
    @person = Person.new(params[:person])

    respond_to do |format|
      if @person.save
        format.html { redirect_to(edit_person_path(@person), :notice => 'Person was successfully created.') }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Update a person
  def update
    @person = Person.get(params[:id])

    respond_to do |format|
      if @person.update(params[:person])
        format.html { redirect_to(edit_person_path(@person), :notice => 'Person was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Destroy a person 
  # TODO: what about objects linking here?
  def destroy
    @person = Person.get(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to(people_url) }
      format.xml  { head :ok }
    end
  end
end
