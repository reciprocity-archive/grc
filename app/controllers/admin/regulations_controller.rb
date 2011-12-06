class Admin::RegulationsController < ApplicationController
  layout "admin"

  # Slug for AJAX
  def slug
    respond_to do |format|
      format.js  { render :json => [Regulation.get(params[:id]).slug]  }
    end
  end

  # List Regulations
  def index
    @regulations = Regulation.all

    respond_to do |format|
      format.html
      format.xml  { render :xml => @regulations }
    end
  end

  # Show reg
  def show
    @regulation = Regulation.get(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @regulation }
    end
  end

  # New reg form
  def new
    @regulation = Regulation.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @regulation }
    end
  end

  # Edit reg form
  def edit
    @regulation = Regulation.get(params[:id])
  end

  # Create a reg
  def create
    source_document = params[:regulation].delete("source_document")
    source_website = params[:regulation].delete("source_website")
    @regulation = Regulation.new(params[:regulation])

    # A couple of attached docs
    @regulation.source_document = Document.new(source_document) if source_document && !source_document['link'].blank?
    @regulation.source_website = Document.new(source_website) if source_website && !source_document['link'].blank?

    respond_to do |format|
      if @regulation.save
        format.html { redirect_to(edit_regulation_path(@regulation), :notice => 'Regulation was successfully created.') }
        format.xml  { render :xml => @regulation, :status => :created, :location => @regulation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @regulation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Update a reg
  def update
    @regulation = Regulation.get(params[:id])

    @regulation.source_document ||= Document.create
    @regulation.source_website ||= Document.create

    # Accumulate results
    results = []
    results << @regulation.source_document.update(params[:regulation].delete("source_document") || {})
    results << @regulation.source_website.update(params[:regulation].delete("source_website") || {})

    # Save if doc updated
    @regulation.save if @regulation.dirty?

    results << @regulation.update(params[:regulation])

    respond_to do |format|
      if results.all?
        format.html { redirect_to(edit_regulation_path(@regulation), :notice => 'Regulation was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @regulation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Delete a reg
  def destroy
    @regulation = Regulation.get(params[:id])
    @regulation.destroy

    respond_to do |format|
      format.html { redirect_to(regulations_url) }
      format.xml  { head :ok }
    end
  end
end
