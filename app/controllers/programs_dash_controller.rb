# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Programs overview
class ProgramsDashController < ApplicationController
  include DashboardHelper

  access_control :acl do
    allow logged_in
  end

  layout 'dashboard'

  def index
    @programs = Program.all.reduce([]) do |progs, program|
      if current_user.has_role?('read', program)
        progs.append(program)
      end
      progs
    end
    init_quick_find
  end
end
