class ObjectDocumentsController < BaseMappingsController

#  access_control :acl do
#    allow :superuser
#
#    actions :index do
#      allow :read, :read_object_document
#    end
#
#    actions :create do
#      allow :create, :create_object_document
#    end
#
#    actions :list_edit, :create do
#      allow :update, :update_object_document
#    end
#  end

  def index
    @object_documents = ObjectDocument
    if params[:object_id]
      @object_documents = @object_documents.where(
        :documentable_type => params[:object_type],
        :documentable_id => params[:object_id])
    end
    @object_documents = allowed_objs(@object_documents.all, :read)

    render :json => @object_documents, :include => { :document => { :methods => [:document_type, :link_url] } }
  end

  private

    def list_edit_context
      super.merge \
        :form_url => url_for(:action => :create, :only_path => true)
    end

    def list_form_context
      super.merge \
        :object => params[:object_type].constantize.find(params[:object_id])
    end

    def update_object(relation, object_params)
      relation.document = Document.find(object_params[:document_id])
      related_object = object_params[:documentable_type].constantize.find(object_params[:documentable_id])
      relation.documentable = related_object
    end

    def default_as_json_options
      { :include => { :document => { :methods => [:document_type, :link_url] } } }
    end
end
