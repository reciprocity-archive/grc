# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2011
# License:: Apache 2.0

# Handle the filter-by-slug form

class SlugfilterController < ActionController::Base
  include SlugfilterHelper

  access_control :acl do
    allow :admin, :analyst
  end

  # Filter-by-slug form changed, memoize the requested prefix and reload - AJAX
  def index
    slug = params[:slugfilter].upcase
    slug = "" if params[:clear]
    session[:slugfilter] = slug
    # TODO restore page state (e.g. drilldown)
    render :js => "window.location.reload()"
  end

  # Supply the list of possible slug prefixes for autocomplete in the form - AJAX
  def values
    render :json => gen_slugs(params[:term].upcase)
  end
end
