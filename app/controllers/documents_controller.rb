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
        @documents.include_root_in_json = false
        render :json => @documents
      end
    end
  end

  def create
    @document = Document.new(params[:document])

    respond_to do |format|
      if @document.save
        flash[:notice] = "Successfully created a new document."
        format.json do
          @document.include_root_in_json=false
          render :json => @document
        end
        format.html { ajax_refresh }
      else
        flash[:error] = "There was an error creating the document."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    @document = Document.new(params[:id])

    respond_to do |format|
      if @document.authored_update(current_user, params[:document])
        flash[:notice] = "Successfully updated the document."
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
end
