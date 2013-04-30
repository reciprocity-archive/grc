# Handle RiskyAttributes
class RiskyAttributesController < BaseObjectsController

#  access_control :acl do
#    # FIXME: Implement real authorization
#
#    allow :superuser
#
#    actions :index do
#      allow :read, :read_risky_attribute
#    end
#
#    actions :new, :create do
#      allow :create, :create_risky_attribute
#    end
#
#    actions :edit, :update do
#      allow :update, :update_risky_attribute, :of => :risky_attribute
#    end
#
#    actions :show, :tooltip do
#      allow :read, :read_risky_attribute, :of => :risky_attribute
#    end
#
#  end
  
  before_filter :check_risk_authorization

  layout 'dashboard'

  def index
    object_set = model_class
    if params[:s].present?
      if object_set.respond_to?(:fulltext_search)
        object_set = object_set.fulltext_search(params[:s])
      else
        object_set = object_set.db_search(params[:s])
      end
    end
    if params[:type_string].present?
      object_set = object_set.where(:type_string => params[:type_string])
    end
    object_set = allowed_objs(object_set.all, :read)
    set_objects(object_set)

    respond_to do |format|
      format.html do
        if params[:quick]
          render :partial => 'quick', :locals => { :quick_result => params[:qr]}
        end
      end
      format.json do
        render :json => objects_as_json
      end
    end
  end

  private

    def risky_attribute_params
      risky_attribute_params = params[:risky_attribute] || {}
      %w(start_date stop_date).each do |field|
        parse_date_param(risky_attribute_params, field)
      end
      risky_attribute_params
    end
    
end
