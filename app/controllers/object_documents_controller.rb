class ObjectDocumentsController < ApplicationController
  include ApplicationHelper

  access_control :acl do
    allow :superuser
  end

  def index
    @objects = ObjectDocument.where(:documentable_type => params[:object_type], :documentable_id => params[:object_id])
    render :json => @objects, :include => :document
  end

  def create
    
  end

  private

    def object_document_params
      params
    end

end
