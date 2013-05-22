class RiskRiskyAttributesController < BaseMappingsController

#  access_control :acl do
#    allow :superuser
#  end
  
  before_filter :check_risk_authorization

  def index
    @objects = RiskRiskyAttribute
    if params[:risk_id].present?
      @objects = @objects.where(:risk_id => params[:risk_id])
    end
    if params[:risky_attribute_id].present?
      @objects = @objects.where(:risky_attribute_id => params[:risky_attribute_id])
    end
    @objects = @objects.all
    render :json => @objects, :include => [:risk, :risky_attribute]
  end

  private

    def list_edit_context
      form_params = {}
      form_params[:risk_id] = params[:risk_id] if params[:risk_id].present?
      form_params[:risky_attribute_id] = params[:risky_attribute_id] if params[:risky_attribute_id].present?

      super.merge \
        :form_url => url_for({ :action => :create, :only_path => true }.merge(form_params))
    end

    def list_form_context
      if params[:risk_id].present?
        object = Risk.find(params[:risk_id])
      elsif params[:risky_attribute_id].present?
        object = RiskyAttribute.find(params[:risky_attribute_id])
      end

      super.merge :object => object
    end

    def update_object(object, object_params)
      object.risk_id = object_params[:risk_id]
      object.risky_attribute_id = object_params[:risky_attribute_id]
    end

    def default_as_json_options
      { :include => [:risk, :risky_attribute] }
    end

end
