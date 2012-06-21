class HelpController < ApplicationController
  layout 'help'

  # Render the requested partial under 'help'
  def show
    help_slug = params[:slug]

    respond_to do |format|
      format.html do
        if request.xhr?
          begin
            render :partial => "help/#{help_slug}", :layout  => 'help_modal'
          rescue
            render :partial => 'default', :layout  => 'help_modal'
          end
        else
          begin
            render "_#{help_slug}"
          rescue
            render '_default'
          end
        end
      end
    end
  end
end
