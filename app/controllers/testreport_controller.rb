class TestreportController < ApplicationController
  include ApplicationHelper

  access_control :acl do
    allow :admin, :analyst
  end

  def index2
    render 'testreport/index'
  end

  def top
    if request.post?
      redirect_to url_for(:action => :top)
    else
      @system_controls = filter_system_controls(SystemControl.all)
      render 'testreport/top'
    end
  end

  def byregulation
    if request.post?
      redirect_to url_for(:action => :byregulation)
    else
      @system_controls = filter_system_controls(SystemControl.all)
      render 'testreport/regulation'
    end
  end

  def byprocess
    if request.post?
      biz_process_id = params[:biz_process][:id]
      if biz_process_id.empty?
        @system_controls = SystemControl.all
      else
        @biz_process = BizProcess.get(biz_process_id)
        @system_controls = SystemControl.all(:control => @biz_process.controls)
      end
      render 'testreport/process'
    else
      @system_controls = SystemControl.all
      render 'testreport/process'
    end
  end
end
