# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2011
# License:: Apache 2.0

# Controller for showing a dashboard consisting of BizProcess -> System -> Control
# tree.

class DashboardController < ApplicationController
  include ApplicationHelper

  access_control :acl do
    allow :superuser, :admin, :analyst
  end

  # Show the collapsed dashboard view, consisting of a (possibly filtered) list of
  # BizProcess objects.
  #
  # We may get a POST here if a filter is changed.
  def index
    if request.post?
      redirect_to url_for
    else
      @biz_processes = filter_biz_processes(BizProcess.all)
    end
  end

  # AJAX for drilldown into a BizProcess
  def openbp
    bp = BizProcess.get(params[:id])
    render :partial => "dashboard/openbp", :locals => {:bp => bp}
  end

  # AJAX for closing a BizProcess drilldown
  def closebp
    bp = BizProcess.get(params[:id])
    render :partial => "dashboard/closebp", :locals => {:bp => bp}
  end

  # AJAX for drilldown into a System
  def opensys
    biz_process = BizProcess.get(params[:biz_process_id])
    system = System.get(params[:id])
    render :partial => "dashboard/opensys", :locals => {:biz_process => biz_process, :system => system}
  end

  # AJAX for closing a System drilldown
  def closesys
    biz_process = BizProcess.get(params[:biz_process_id])
    system = System.get(params[:id])
    render :partial => "dashboard/closesys", :locals => {:biz_process => biz_process, :system => system}
  end

end
