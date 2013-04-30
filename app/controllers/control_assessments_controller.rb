# Handle Control Assessments
class ControlAssessmentsController < BaseObjectsController

#  access_control :acl do
#    # FIXME: Implement real authorization
#
#    allow :superuser
#
#    actions :index do
#      allow :read, :read_control_assessment
#    end
#
#    actions :new, :create do
#      allow :create, :create_control_assessment
#    end
#
#    actions :edit, :update do
#      allow :update, :update_control_assessment, :of => :control_assessment
#    end
#
#    actions :show, :tooltip do
#      allow :read, :read_control_assessment, :of => :control_assessment
#    end
#
#  end

  before_filter :load_object, :only => :rotate

  def rotate
    param = params[:control_assessment]
    if param.present? && param.is_a?(Hash)
      %w(internal_tod internal_toe external_tod external_toe).each do |field|
        value = param[field]
        if value == 'toggle'
          @control_assessment.rotate_value!(field)
        end
      end
    end

    render :text => ''
  end

end
