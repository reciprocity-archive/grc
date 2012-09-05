class Admin::ProgramsController < ApplicationController
  layout "admin"

  # Slug for AJAX
  def slug
    respond_to do |format|
      format.js  { render :json => [Program.find(params[:id]).slug]  }
    end
  end

  # List Programs
  def index
    @programs = allowed_objs(Program.all, :read)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @programs }
    end
  end

  ## Show reg
  #def show
  #  @program = Program.find(params[:id])
  #
  #  respond_to do |format|
  #    format.html
  #    format.xml  { render :xml => @program }
  #  end
  #end

  # New reg form
  def new
    @program = Program.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @program }
    end
  end

  # Edit reg form
  def edit
    @program = Program.find(params[:id])
  end

  # Create a reg
  def create
    source_document = params[:program].delete("source_document")
    source_website = params[:program].delete("source_website")
    @program = Program.new(params[:program])

    # A couple of attached docs
    @program.source_document = Document.new(source_document) if source_document && !source_document['link'].blank?
    @program.source_website = Document.new(source_website) if source_website && !source_document['link'].blank?

    respond_to do |format|
      if @program.save
        format.html { redirect_to(edit_program_path(@program), :notice => 'Program was successfully created.') }
        format.xml  { render :xml => @program, :status => :created, :location => @program }
      else
        flash.now[:error] = "Could not create."
        format.html { render :action => "new" }
        format.xml  { render :xml => @program.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Update a reg
  def update
    @program = Program.find(params[:id])

    @program.source_document ||= Document.create
    @program.source_website ||= Document.create

    # Accumulate results
    results = []
    results << @program.source_document.update_attributes(params[:program].delete("source_document") || {})
    results << @program.source_website.update_attributes(params[:program].delete("source_website") || {})

    # Save if doc updated
    @program.save if @program.changed?

    results << @program.update_attributes(params[:program])

    respond_to do |format|
      if results.all?
        format.html { redirect_to(edit_program_path(@program), :notice => 'Program was successfully updated.') }
        format.xml  { head :ok }
      else
        flash.now[:error] = "Could not update."
        format.html { render :action => "edit" }
        format.xml  { render :xml => @program.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Delete a reg
  def destroy
    @program = Program.find(params[:id])
    @program.destroy

    respond_to do |format|
      format.html { redirect_to(programs_url) }
      format.xml  { head :ok }
    end
  end
end
