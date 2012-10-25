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

    actions :index do
      allow :read_document
    end

    actions :edit, :update do
      allow :update, :update_document, :of => :document
    end

    actions :destroy do
      allow :destroy, :delete_document, :of => :document
    end
  end

  layout 'dashboard'

  def index
    @objects = Document
    if params[:s]
      @objects = @objects.db_search(params[:s])
    end
    render :json => @objects.all
  end

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
          render :json => @document.as_json(:root => nil, :methods => [:descriptor, :link_url]), :location => nil
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
          render :json => @document.as_json(:root => nil, :methods => [:descriptor, :link_url]), :location => nil
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

  private
    def load_document
      @document = Document.find(params[:id])
    end

    def document_params
      document_params = params[:document] || {}
      document_params
    end
end
