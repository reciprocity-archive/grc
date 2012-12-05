# Author:: Slobodan Kovacevic (mailto:basti@reciprocitynow.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class OptionsController < BaseObjectsController

  access_control :acl do
    allow :superuser
  end

  layout 'dashboard'

  def index
    @options = Option.all
    if params[:s]
      @options = @options.db_search(params[:s])
    end
    render :json => @options.all.as_json
  end

end
