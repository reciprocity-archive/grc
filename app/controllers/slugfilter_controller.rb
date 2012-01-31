# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2011
# License:: Apache 2.0

# Handle the filter-by-slug form

class SlugfilterController < ApplicationController
  include SlugfilterHelper

  access_control :acl do
    allow :admin, :analyst
  end

  # Update the last-used regulation in the session so that the user
  # gets it as a default next time.
  def regulation_update
    regulation_id = params[:regulation][:id] rescue nil
    if !regulation_id.nil?
      if regulation_id == ""
        session[:regulation_id] = nil
      else
        session[:regulation_id] = regulation_id
      end
    end
    # TODO restore page state (e.g. drilldown)
    render :js => "window.location.reload()"
  end

  # Update the audit cycle
  def cycle_update
    cycle_id = params[:cycle][:id] rescue nil
    if !cycle_id.nil?
      if cycle_id == ""
        session[:cycle_id] = nil
      else
        session[:cycle_id] = cycle_id
      end
    end
    # TODO restore page state (e.g. drilldown)
    render :js => "window.location.reload()"
  end

  # Filter-by-slug form changed, memoize the requested prefix and reload - AJAX
  def slug_update
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
