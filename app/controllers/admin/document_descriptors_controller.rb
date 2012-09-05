class Admin::DocumentDescriptorsController < ApplicationController
  layout "admin"

  # List Document Descriptors
  def index
    @document_descriptors = DocumentDescriptor.where({})

    respond_to do |format|
      format.html
      format.xml  { render :xml => @document_descriptors }
    end
  end

  # FIXME: No template!
  ## Show a descriptor
  #def show
  #  @document_descriptor = DocumentDescriptor.find(params[:id])
  #
  #  respond_to do |format|
  #    format.html
  #    format.xml  { render :xml => @document_descriptor }
  #  end
  #end

  # New descriptor form
  def new
    @document_descriptor = DocumentDescriptor.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @document_descriptor }
    end
  end

  # Edit descriptor form
  def edit
    @document_descriptor = DocumentDescriptor.find(params[:id])
  end

  # Create a descriptor
  def create
    @document_descriptor = DocumentDescriptor.new(params[:document_descriptor])

    respond_to do |format|
      if @document_descriptor.save
        format.html { redirect_to(edit_document_descriptor_path(@document_descriptor), :notice => 'DocumentDescriptor was successfully created.') }
        format.xml  { render :xml => @document_descriptor, :status => :created, :location => @document_descriptor }
      else
        flash.now[:error] = "Could not create."
        format.html { render :action => "new" }
        format.xml  { render :xml => @document_descriptor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Update a descriptor
  def update
    @document_descriptor = DocumentDescriptor.find(params[:id])

    respond_to do |format|
      if @document_descriptor.update_attributes(params[:document_descriptor])
        format.html { redirect_to(edit_document_descriptor_path(@document_descriptor), :notice => 'DocumentDescriptor was successfully updated.') }
        format.xml  { head :ok }
      else
        flash.now[:error] = "Could not update."
        format.html { render :action => "edit" }
        format.xml  { render :xml => @document_descriptor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Delete a descriptor
  def destroy
    @document_descriptor = DocumentDescriptor.find(params[:id])
    @document_descriptor.destroy

    respond_to do |format|
      format.html { redirect_to(document_descriptors_url) }
      format.xml  { head :ok }
    end
  end
end
