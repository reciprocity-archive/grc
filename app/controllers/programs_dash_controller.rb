# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Programs overview
class ProgramsDashController < ApplicationController
  def index
    @programs = Program.all
  end
end
