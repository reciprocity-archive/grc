class HelpController < ApplicationController
  layout 'help'

#  access_control :acl do
#    allow logged_in
#  end

  # Render the requested partial under 'help'
  def edit
    slug = params[:help]['slug']
    @help = Help.find_by_slug(slug) ||
      Help.new(:slug => slug)
    @help.title = params[:help]['title']
    @help.content = params[:help]['content']
    respond_to do |format|
      if CMS_CONFIG["ALLOW_HELP_EDIT"] && @help.save
        format.json do
          flash[:notice] = "Help was saved successfully."
          render :json => @help
        end
      else
        format.json do
          render :json => {:error => "could not save"}
        end
      end
    end
  end

  def show
    @help_slug = params[:slug]
    @help = Help.find_by_slug(@help_slug) || Help.new(slug: @help_slug)

    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => 'help', :layout  => 'help_modal'
        else
          render '_help', :layout => 'dashboard'
        end
      end
    end
  end
end
