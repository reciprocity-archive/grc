class Admin::DocumentDescriptorsController < ApplicationController
  layout "admin"

  def index
    @document_descriptors = DocumentDescriptor.all

    respond_to do |format|
      format.html
      format.xml  { render :xml => @document_descriptors }
    end
  end

  def show
    @document_descriptor = DocumentDescriptor.get(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @document_descriptor }
    end
  end

  def new
    @document_descriptor = DocumentDescriptor.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @document_descriptor }
    end
  end

  def edit
    @document_descriptor = DocumentDescriptor.get(params[:id])
  end

  def create
    @document_descriptor = DocumentDescriptor.new(params[:document_descriptor])

    respond_to do |format|
      if @document_descriptor.save
        format.html { redirect_to(edit_document_descriptor_path(@document_descriptor), :notice => 'DocumentDescriptor was successfully created.') }
        format.xml  { render :xml => @document_descriptor, :status => :created, :location => @document_descriptor }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @document_descriptor.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @document_descriptor = DocumentDescriptor.get(params[:id])

    respond_to do |format|
      if @document_descriptor.update(params[:document_descriptor])
        if params[:document_descriptor][:password]
          @document_descriptor.crypted_password = nil
          @document_descriptor.save
        end

        format.html { redirect_to(edit_document_descriptor_path(@document_descriptor), :notice => 'DocumentDescriptor was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @document_descriptor.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @document_descriptor = DocumentDescriptor.get(params[:id])
    @document_descriptor.destroy

    respond_to do |format|
      format.html { redirect_to(document_descriptors_url) }
      format.xml  { head :ok }
    end
  end
end
