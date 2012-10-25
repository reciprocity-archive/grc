class ObjectDocumentsController < BaseMappingsController

  access_control :acl do
    allow :superuser

    actions :index do
      allow :read, :read_document
    end

    actions :list_edit, :create do
      allow :update, :update_document
    end
  end

  def index
    @objects = ObjectDocument
    if params[:object_id]
      @objects = @objects.where(
        :documentable_type => params[:object_type],
        :documentable_id => params[:object_id])
    end
    render :json => @objects, :include => :document
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
end
