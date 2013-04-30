class ControlRisksController < BaseMappingsController

#  access_control :acl do
#    allow :superuser
#  end

  def index
    @objects = ControlRisk
    if params[:risk_id].present?
      @objects = @objects.where(:risk_id => params[:risk_id])
    end
    if params[:control_id].present?
      @objects = @objects.where(:control_id => params[:control_id])
    end
    @objects = @objects.all
    render :json => @objects, :include => [:control, :risk]
  end

  private

    def list_edit_context
      form_params = {}
      form_params[:risk_id] = params[:risk_id] if params[:risk_id].present?
      form_params[:control_id] = params[:control_id] if params[:control_id].present?

      super.merge \
        :form_url => url_for({ :action => :create, :only_path => true }.merge(form_params))
    end

    def list_form_context
      if params[:risk_id].present?
        object = Risk.find(params[:risk_id])
      elsif params[:control_id].present?
        object = Control.find(params[:control_id])
      end

      super.merge :object => object
    end

    def update_object(object, object_params)
      object.risk_id = object_params[:risk_id]
      object.control_id = object_params[:control_id]
    end
end
