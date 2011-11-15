class Admin::DocumentsController < ApplicationController
  layout "admin"

  # List documents
  def index
    @documents = Document.all

    respond_to do |format|
      format.html
      format.xml  { render :xml => @documents }
    end
  end

  # Show a doc
  def show
    @document = Document.get(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @document }
    end
  end

  # New doc form
  def new
    @document = Document.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @document }
    end
  end

  # Edit doc form
  def edit
    @document = Document.get(params[:id])
  end

  # Create a doc
  def create
    @document = Document.new(params[:document])

    respond_to do |format|
      if @document.save
        format.html { redirect_to(edit_document_path(@document), :notice => 'Document was successfully created.') }
        format.xml  { render :xml => @document, :status => :created, :location => @document }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Update a doc
  def update
    @document = Document.get(params[:id])

    respond_to do |format|
      if @document.update(params[:document])
        format.html { redirect_to(edit_document_path(@document), :notice => 'Document was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Delete a doc
  def destroy
    @document = Document.get(params[:id])
    @document.destroy

    respond_to do |format|
      format.html { redirect_to(documents_url) }
      format.xml  { head :ok }
    end
  end
end
