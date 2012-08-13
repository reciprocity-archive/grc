# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle Documents
class DocumentsController < ApplicationController
  include ApplicationHelper

  access_control :acl do
    allow :superuser, :admin, :analyst
  end

  layout 'dashboard'

  def edit
    @document = Document.find(params[:id])
    render :layout => nil
  end

  def show
    @document = Document.find(params[:id])
  end

  def tooltip
    @document = Document.find(params[:id])
    render :layout => nil
  end

  def new
    @document = Document.new(params[:document])
    render :layout => nil
  end

  def list
    @documents = Document.where({})
    if params[:s] && !params[:s].blank?
      @documents = @documents.where(:title => params[:s])
    end
    respond_to do |format|
      format.html { render :layout => nil }
      format.json do
        render :json => @documents.as_json(:root => nil, :methods => [:descriptor, :link_url])
      end
    end
  end

  def list_edit
    @object = params[:object_type].classify.constantize.find(params[:object_id])
    #@documents = Document.where({})
    render :layout => nil
  end

  def list_update
    @object = params[:object_type].classify.constantize.find(params[:object_id])

    new_object_documents = []

    if params[:items]
      params[:items].each do |_, item|
        object_document = @object.object_documents.where(:document_id => item[:id]).first
        if !object_document
          object_document = @object.object_documents.new(:document_id => item[:id])
        end
        new_object_documents.push(object_document)
      end
    end

    @object.object_documents = new_object_documents

    respond_to do |format|
      if @object.save
        format.json do
          render :json => @object.object_documents.all.map { |od| od.as_json_with_role_and_document(:root => nil, :methods => [:descriptor, :link_url]) }
        end
        format.html
      else
        flash[:error] = "Could not update attached documents"
        format.html { render :layout => nil }
      end
    end
  end

  def create
    @document = Document.new(params[:document])

    respond_to do |format|
      if @document.save
        flash[:notice] = "Successfully created a new document."
        format.json do
          render :json => @document.as_json(:root => nil, :methods => [:descriptor, :link_url])
        end
        format.html { ajax_refresh }
      else
        flash[:error] = "There was an error creating the document."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    @document = Document.find(params[:id])

    respond_to do |format|
      if @document.authored_update(current_user, params[:document])
        flash[:notice] = "Successfully updated the document."
        format.json do
          render :json => @document.as_json(:root => nil, :methods => [:descriptor, :link_url])
        end
        format.html { redirect_to flow_document_path(@document) }
      else
        flash[:error] = "There was an error updating the document."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def index
    @documents = Document.all
  end

  def destroy
    @document = Document.find(params[:id])
    @document.destroy
  end
end
