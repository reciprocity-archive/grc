# Handle Responses
class ResponsesController < BaseObjectsController

#  access_control :acl do
#    # FIXME: Implement real authorization
#
#    allow :superuser
#
#    actions :index do
#      allow :read, :read_response
#    end
#
#    actions :new, :create do
#      allow :create, :create_response
#    end
#
#    actions :edit, :update do
#      allow :update, :update_response, :of => :response
#    end
#
#    actions :show, :tooltip do
#      allow :read, :read_response, :of => :response
#    end
#
#  end

  layout 'dashboard'

  def index
    object_set = model_class

    if params[:request_id].present?
      object_set = object_set.where(:request_id => params[:request_id])
    end

    if params[:s].present?
      if object_set.respond_to?(:fulltext_search)
        object_set = object_set.fulltext_search(params[:s])
      else
        object_set = object_set.db_search(params[:s])
      end
    end
    object_set = allowed_objs(object_set.all, :read)
    set_objects(object_set)

    respond_to do |format|
      format.json do
        render :json => objects_as_json
      end
    end
  end

  private

    def object_as_json(args=nil)
      object.as_json_with_system(:root => nil)
    end

    def objects_as_json
      objects.map {|object| object.as_json_with_system }.as_json
    end

    def object_path
      flow_pbc_list_path(object.request.pbc_list_id)
    end

    def post_destroy_path
      flow_pbc_list_path(object.request.pbc_list_id)
    end

    def response_params
      response_params = params[:response] || {}

      request_id = response_params.delete(:request_id)
      if request_id.present?
        request = Request.where(:id => request_id).first
        if request.present?
          response_params[:request] = request
        end
      end

      if response_params.has_key? :system_id then
        system = System.where(:id => response_params.delete(:system_id)).first
        response_params[:system] = system
      end
      response_params
    end
end
