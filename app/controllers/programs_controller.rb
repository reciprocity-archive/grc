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

  def new
    @program = Program.new(params[:program])

    render :layout => nil
  end

  def edit
    @program = Program.find(params[:id])
    if @program.previous_version
      @program = @program.previous_version
    end

    render :layout => nil
  end

  def create
    source_document = params[:program].delete(:source_document)
    source_website = params[:program].delete(:source_website)
    params[:program][:company] = params[:program].delete(:type) == 'company'

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

    #@program.source_document ||= Document.create
    #@program.source_website ||= Document.create

    # Accumulate results
    results = []
    #results << @program.source_document.update_attributes(params[:program].delete("source_document") || {})
    #results << @program.source_website.update_attributes(params[:program].delete("source_website") || {})
    params[:program][:company] = params[:program].delete(:type) == 'company'

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
    render :layout => '_tooltip', :locals => { :program => @program }
  end

  def sections
    @program = Program.find(params[:id])
    @sections = @program.sections.includes(:controls => :implementing_controls)
    if params[:s]
      @sections = @sections.search(params[:s])
    end
    @sections.all.sort_by(&:slug_split_for_sort)
    render :layout => nil, :locals => { :sections => @sections }
  end

  def controls
    @program = Program.find(params[:id])
    @controls = @program.controls.includes(:implementing_controls)
    if params[:s]
      @controls = @controls.search(params[:s])
    end
    @controls.all.sort_by(&:slug_split_for_sort)
    render :layout => nil, :locals => { :controls => @controls }
  end

  def section_controls
    @program = Program.find(params[:id])
    if @program.company?
      @sections = @program.controls.includes(:implemented_controls => { :control_sections => :section }).map { |cc| cc.implemented_controls.map { |ic| ic.control_sections.map { |cs| cs.section } }.flatten }.flatten.uniq
    else
      @sections = @program.sections.includes(:controls => :implementing_controls).all
    end

    @sections.sort_by(&:slug_split_for_sort)
    render :layout => nil, :locals => { :sections => @sections }
  end

  def control_sections
    @program = Program.find(params[:id])
    @controls = @program.controls.includes(:sections)
    if params[:s]
      @controls = @controls.search(params[:s])
    end
    @controls.all.sort_by(&:slug_split_for_sort)
    render :layout => nil, :locals => { :controls => @controls }
  end

  def category_controls
    @program = Program.find(params[:id])

    @category_tree = Category.roots.all.map do |category|
      branches = category.children.all.map do |subcategory|
        controls = subcategory.controls.where(:program_id => @program.id).all
        if !controls.empty?
          [subcategory, controls]
        end
      end.compact
      if !branches.empty?
        [category, branches]
      end
    end.compact

    uncategorized_controls = Control.
      includes(:categorizations).
      where(
        :program_id => @program.id,
        :categorizations => { :categorizable_id => nil }).
      all

    if !uncategorized_controls.empty?
      @category_tree.push([nil, uncategorized_controls])
    end

    render :layout => nil, :locals => { }
  end
end
