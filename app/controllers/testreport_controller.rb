# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2011
# License:: Apache 2.0

# Report on the results of analyst testing for an audit

class TestreportController < ApplicationController
  include ApplicationHelper

  access_control :acl do
    allow :superuser
  end

  before_filter :need_cycle

  # Show top issues
  def top
    if request.post?
      redirect_to url_for
    else
      @system_controls = filter_system_controls(SystemControl.where(:cycle_id => @cycle))
    end
  end

  # Show issues by program
  def byprogram
    if request.post?
      redirect_to url_for
    else
      @system_controls = filter_system_controls(SystemControl.where(:cycle_id => @cycle))
    end
  end

  # Show issues by business process, potentially filtering by process
  def byprocess
    if request.post?
      biz_process_id = params[:biz_process][:id]
      if biz_process_id.empty?
        @system_controls = SystemControl.where(:cycle_id => @cycle)
      else
        @biz_process = BizProcess.find(biz_process_id)
        @system_controls =
          filter_system_controls(SystemControl.where(:cycle_id => @cycle, :control_id => @biz_process.controls))
      end
    else
      @system_controls = SystemControl.where(:cycle_id => @cycle)
    end
  end
end
