# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class CyclesController < ApplicationController

  layout 'dashboard'

  def show
    @cycle = Cycle.find(params[:id])
  end
end
