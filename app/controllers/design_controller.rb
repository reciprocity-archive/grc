# Handle unincorporated design views here
class DesignController < ApplicationController
  include ApplicationHelper

  layout 'dashboard'

  before_filter :require_design_feature

  # Render the requested partial under 'design/templates'
  def templates
    template_name = params[:name]

    respond_to do |format|
      format.html do
        if request.xhr?
          begin
            render :partial => "design/templates/#{template_name}"
          #rescue
          #  render :partial => 'design/templates/comingsoon'
          end
        else
          begin
            render "design/templates/_#{template_name}", :layout => false
          #rescue
          #  render 'design/templates/_comingsoon', :layout => false
          end
        end
      end
    end
  end

  private

    def require_design_feature
      if !has_feature? :BETA
        raise AbstractController::ActionNotFound, "The action '#{action_name}' could not be found for #{self.class.name}"
      end
    end
end
