class TestingController < ApplicationController
  include ApplicationHelper

  def index
    if request.post?
      redirect_to url_for(:action => :index)
    else
      @systems = filter_systems(System.all)
      render 'testing/index'
    end
  end

  def show
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    render :partial => "testing/control", :locals => {:sc => sc}
  end

  def show_closed
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    render :partial => "testing/closed_control", :locals => {:sc => sc}
  end

  def update_control_state
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    value = params[:value]
    sc.state = value.to_sym
    sc.save!
    render :partial => "testing/control", :locals => {:sc => sc}
  end

  def edit_control_text
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    render :partial => "testing/control_text_form", :locals => {:sc => sc}
  end

  def update_control_text
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    sc.update!(params[:system_control])
    render :partial => "testing/control", :locals => {:sc => sc}
  end

  def review
    document_id = params[:document_id]
    document = Document.get(document_id)
    document.reviewed = params[:value] != "maybe"
    document.good = params[:value] == "1"
    document.save!
    render :partial => 'testing/document', :locals => {:document => document}
  end
end
