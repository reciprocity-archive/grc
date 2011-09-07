class DashboardController < ApplicationController
  include ApplicationHelper

  def index
    if request.post?
      redirect_to url_for
    else
      @biz_processes = filter_biz_processes(BizProcess.all)
    end
  end

  def openbp
    bp = BizProcess.get(params[:id])
    render :partial => "dashboard/openbp", :locals => {:bp => bp}
  end

  def closebp
    bp = BizProcess.get(params[:id])
    render :partial => "dashboard/closebp", :locals => {:bp => bp}
  end

  def opensys
    biz_process = BizProcess.get(params[:biz_process_id])
    system = System.get(params[:id])
    render :partial => "dashboard/opensys", :locals => {:biz_process => biz_process, :system => system}
  end

  def closesys
    biz_process = BizProcess.get(params[:biz_process_id])
    system = System.get(params[:id])
    render :partial => "dashboard/closesys", :locals => {:biz_process => biz_process, :system => system}
  end

end
