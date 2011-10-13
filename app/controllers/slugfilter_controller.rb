class SlugfilterController < ActionController::Base
  include SlugfilterHelper

  access_control :acl do
    allow :admin, :analyst
  end

  def index
    slug = params[:slugfilter].upcase
    slug = "" if params[:clear]
    session[:slugfilter] = slug
    render :js => "window.location.reload()"
  end

  def values
    render :json => gen_slugs(params[:term].upcase)
  end
end
