# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2011
# License:: Apache 2.0

# Handle data input for the testing phase of an audit

class TestingController < ApplicationController
  include ApplicationHelper

  access_control :acl do
    allow :superuser, :admin, :analyst
  end

  # Show the collapsed testing view, consisting of the (possibly filtered) list of systems.
  #
  # We may get a POST here if a filter is changed.
  def index
    if request.post?
      redirect_to url_for
    else
      @systems = filter_systems(System.all)
    end
  end

  # Drilldown into a control - AJAX
  def show
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    render :partial => "control", :locals => {:sc => sc}
  end

  # Close drilldown into a control - AJAX
  def show_closed
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    render :partial => "closed_control", :locals => {:sc => sc}
  end

  # Set the state of a control (green/red/yellow) - AJAX
  def update_control_state
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    value = params[:value]
    sc.state = value.to_sym
    sc.save!
    render :partial => "control", :locals => {:sc => sc}
  end

  # Show the textual state of a control (why/impact/recommendation) - AJAX
  def edit_control_text
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    render :partial => "control_text_form", :locals => {:sc => sc}
  end

  # Set the textual state of a control (why/impact/recommendation) - AJAX
  def update_control_text
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    sc.update!(params[:system_control])
    render :partial => "control", :locals => {:sc => sc}
  end

  # Review a document (pass/fail/maybe)
  def review
    document_id = params[:document_id]
    document = Document.get(document_id)
    document.reviewed = params[:value] != "maybe"
    document.good = params[:value] == "1"
    document.save!
    render :partial => 'document', :locals => {:document => document}
  end
end
