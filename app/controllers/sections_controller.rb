# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Browse sections
class SectionsController < ApplicationController
  include ApplicationHelper
  include ProgramsHelper

  access_control :acl do
    allow :superuser, :admin, :analyst
  end

  layout 'dashboard'

  def tooltip
    @section = Section.find(params[:id])
    render :layout => nil
  end
end
