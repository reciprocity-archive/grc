class SystemSystemsController < BaseMappingsController

#  access_control :acl do
#    allow :superuser
#  end

  def index
    @objects = SystemSystem
    if params[:parent_id].present?
      @objects = @objects.where(:parent_id => params[:parent_id])
    end
    render :json => @objects, :include => :child
  end

  private

    def list_edit_context
      super.merge \
        :form_url => url_for(:action => :create, :parent_id => params[:parent_id], :only_path => true)
    end

    def list_form_context
      super.merge \
        :object => System.find(params[:parent_id])
    end

    def update_object(object, object_params)
      object.parent_id = object_params[:parent_id]
      object.child_id = object_params[:child_id]
    end
end
