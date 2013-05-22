# Handle Requests
class RequestsController < BaseObjectsController

#  access_control :acl do
#    # FIXME: Implement real authorization
#
#    allow :superuser
#
#    actions :index do
#      allow :read, :read_request
#    end
#
#    actions :new, :create do
#      allow :create, :create_request
#    end
#
#    actions :edit, :update do
#      allow :update, :update_request, :of => :request
#    end
#
#    actions :show, :tooltip do
#      allow :read, :read_request, :of => :request
#    end
#
#  end

  layout 'dashboard'

  private

    def object_path
      flow_pbc_list_path(object.pbc_list_id)
    end

    def post_destroy_path
      flow_pbc_list_path(object.pbc_list_id)
    end

    def request_params
      request_params = params[:request] || {}

      pbc_list_id = request_params.delete(:pbc_list_id)
      if pbc_list_id.present?
        pbc_list = PbcList.where(:id => pbc_list_id).first
        if pbc_list.present?
          request_params[:pbc_list] = pbc_list
        end
      end

      control_id = request_params.delete(:control_id)
      if control_id.present?
        control = Control.where(:id => control_id).first
        pbc_list = request_params[:pbc_list] || @request.pbc_list
        if control && pbc_list
          control_assessment = ControlAssessment.where(
            :pbc_list_id => pbc_list.id,
            :control_id => control.id).first
          control_assessment ||= ControlAssessment.new(
            :pbc_list => pbc_list,
            :control => control)
          request_params[:control_assessment] = control_assessment
        end
      end

      #%w(type).each do |field|
      #  parse_option_param(request_params, field)
      #end
      %w(date_requested response_due_at).each do |field|
        parse_date_param(request_params, field)
      end
      request_params
    end

    def delete_model_stats
      [
        [ 'Response', @request.responses.count ]
      ]
    end
end
