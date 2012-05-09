# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Browse programs
class ProgramsController < ApplicationController
  include ApplicationHelper
  include ProgramsHelper

  access_control :acl do
    allow :superuser, :admin, :analyst
  end

  def show
    @program = Program.find(params[:id])
    @stats = program_stats(@program)
  end
end
