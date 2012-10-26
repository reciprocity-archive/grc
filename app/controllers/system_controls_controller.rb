class SystemControlsController < BaseMappingsController

  access_control :acl do
    allow :superuser
  end

  def index
    @objects = SystemControl
    if params[:system_id].present?
      @objects = @objects.where(:system_id => params[:system_id])
    end
    @objects = @objects.all
    render :json => @objects, :include => :control
  end

  private

    def list_edit_context
      super.merge \
        :form_url => url_for(:action => :create, :system_id => params[:system_id], :only_path => true)
    end

    def list_form_context
      super.merge \
        :object => System.find(params[:system_id])
    end

    def update_object(object, object_params)
      object.system_id = object_params[:system_id]
      object.control_id = object_params[:control_id]
    end
end
