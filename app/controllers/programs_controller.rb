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

  layout 'dashboard'

  def show
    @program = Program.find(params[:id])
    @stats = program_stats(@program)
  end

  def import
    @program = Program.find(params[:id])
  end

  def create
    source_document = params[:program].delete(:source_document)
    source_website = params[:program].delete(:source_website)
    @program = Program.new(params[:program])

    @program.source_document = Document.new(source_document) if source_document && !source_document['link'].blank?
    @program.source_website = Document.new(source_website) if source_website && !source_website['link'].blank?

    respond_to do |format|
      if @program.save
        flash[:notice] = "Program was created successfully."
        format.html do
          redirect_to flow_program_path(@program)
        end
      else
        flash[:error] = "There was an error creating the program"
        format.html do
          if request.xhr?
            render :layout => nil, :status => 400
          end
        end
      end
    end
  end

  def update
    @program = Program.find(params[:id])

    @program.source_document ||= Document.create
    @program.source_website ||= Document.create

    # Accumulate results
    results = []
    results << @program.source_document.update_attributes(params[:program].delete("source_document") || {})
    results << @program.source_website.update_attributes(params[:program].delete("source_website") || {})

    # Save if doc updated
    @program.save if @program.changed?

    results << @program.update_attributes(params[:program])

    respond_to do |format|
      if results.all?
        flash[:notice] = 'Program was successfully updated.'
        format.html { ajax_refresh }
      else
        flash[:error] = "There was an error updating the program"
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def tooltip
    @program = Program.find(params[:id])
    @stats = program_stats(@program)
    render :layout => nil
  end
end
