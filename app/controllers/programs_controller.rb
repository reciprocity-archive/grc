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

  def create
    source_document = params[:program].delete(:source_document)
    source_website = params[:program].delete(:source_website)
    @program = Program.new(params[:program])

    @program.source_document = Document.new(source_document)
    @program.source_website = Document.new(source_website)

    if @program.save
      flash[:notice] = "Program was created successfully."
      render :json => { :redirect => flow_program_path(@program) }
    else
      flash[:error] = "Could not create program."
      render :json => { :errors => @program.error_messages }
    end
  end

  def tooltip
    @program = Program.find(params[:id])
    @stats = program_stats(@program)
    render :layout => nil
  end
end
