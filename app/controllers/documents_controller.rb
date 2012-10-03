# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle Documents
class DocumentsController < ApplicationController
  include ApplicationHelper

  before_filter :load_document, :only => [:edit,
                                          :show,
                                          :tooltip,
                                          :update,
                                          :delete,
                                          :destroy]

  access_control :acl do
    allow :superuser

    actions :create, :new do
      allow :create, :create_document
    end

    actions :show do
      allow :read, :read_document, :of => :document
    end

    # FIXME: no template!
    #actions :index do
    #  allow :read_document
    #end

    actions :edit, :update do
      allow :update, :update_document, :of => :document
    end

    actions :destroy do
      allow :destroy, :delete_document, :of => :document
    end

    actions :list do
      allow :read, :read_document
    end

    actions :list_update, :list_edit do
      allow :update, :update_document
    end
  end

  layout 'dashboard'

  # FIXME: No template!
  #def index
  #  @documents = Document.all
  #end

  # FIXME: No template
  #def show
  #end

  def new
    @document = Document.new(document_params)
    render :layout => nil
  end

  def edit
    render :layout => nil
  end

  def create
    # FIXME: We may not need document descriptor at all, but we still
    # need deal with mass assignment of it.
    document_descriptor_id = document_params.delete(:descriptor_id)
    @document = Document.new(document_params)
    if document_descriptor_id
      @document.descriptor = DocumentDescriptor.find(document_descriptor_id)
    end

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
    respond_to do |format|
      if @document.authored_update(current_user, document_params)
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

  def delete
    @model_stats = []
    @relationship_stats = []
    @relationship_stats << [ 'Object', @document.object_documents.count ]

    respond_to do |format|
      format.json { render :json => @document.as_json(:root => nil) }
      format.html do
        render :layout => nil, :template => 'shared/delete_confirm',
          :locals => { :model => @document, :url => flow_document_path(@document), :models => @model_stats, :relationships => @relationship_stats }
      end
    end
  end

  def destroy
    @document.destroy
    flash[:notice] = "Document deleted"
    respond_to do |format|
      format.html { redirect_to programs_dash_path }
      format.json { render :json => @document.as_json(:root => nil) }
    end
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
    if !params[:object_type] || !params[:object_id]
      return 400
    end
    @object = params[:object_type].classify.constantize.find(params[:object_id])
    #@documents = Document.where({})
    render :layout => nil
  end

  def list_update
    if !params[:object_type] || !params[:object_id]
      return 400
    end

    @object = params[:object_type].classify.constantize.find(params[:object_id])

    new_object_documents = []

    if params[:items]
      params[:items].each do |_, item|
        object_document = @object.object_documents.where(:document_id => item[:id]).first
        if !object_document
          document = Document.find(item[:id])
          object_document = @object.object_documents.new(:document => document)
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

  private
    def load_document
      @document = Document.find(params[:id])
    end

    def document_params
      document_params = params[:document] || {}
      document_params
    end
end
