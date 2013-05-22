class MeetingsController < BaseObjectsController

#  access_control :acl do
#    allow :superuser
#  end

  layout 'dashboard'

  no_base_action :index, :show, :tooltip

  private

    def object_path
      flow_pbc_list_path(@meeting.response.request.pbc_list_id)
    end

    def post_destroy_path
      flow_pbc_list_path(@meeting.response.request.pbc_list_id)
    end

    def meeting_params
      meeting_params = params[:meeting] || {}
      if meeting_params[:response_id]
        meeting_params[:response] = Response.where(:id => meeting_params.delete(:response_id)).first
      end
      meeting_params
    end
end
