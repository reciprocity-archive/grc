# Handle PBC Lists
class ResponsesController < BaseObjectsController

  access_control :acl do
    # FIXME: Implement real authorization

    allow :superuser

    actions :index do
      allow :read, :read_response
    end

    actions :new, :create do
      allow :create, :create_response
    end

    actions :edit, :update do
      allow :update, :update_response, :of => :response
    end

    actions :show, :tooltip do
      allow :read, :read_response, :of => :response
    end

  end

  layout 'dashboard'

  private

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

      system_id = response_params.delete(:system_id)
      if system_id.present?
        system = System.where(:id => system_id).first
        if system.present?
          response_params[:system] = system
        end
      end
      response_params
    end
end
