# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Browse programs
class ProgramsController < ApplicationController
  include ApplicationHelper
  include ProgramsHelper

  # FIXME: Decide if the :section, controls, etc.
  # methods should be moved, and what access controls they
  # need.
  before_filter :load_program, :only => [:show,
                                         :import,
                                         :tooltip,
                                         :edit,
                                         :update,
                                         :sections,
                                         :controls,
                                         :section_controls,
                                         :control_sections,
                                         :category_controls]

  access_control :acl do
    allow :superuser

    allow :create, :create_program, :to => [:create,
                                   :new]
    allow :read, :read_program, :of => :program, :to => [:show,
                                                  :tooltip,
                                                  :sections,
                                                  :controls,
                                                  :section_controls,
                                                  :control_sections,
                                                  :category_controls]

    allow :update, :update_program, :of => :program, :to => [:edit,
                                                    :update,
                                                    :import]
  end

  layout 'dashboard'

  def index
    @programs = Program
    if params[:relevant_to]
      @programs = @programs.relevant_to(Product.find(params[:relevant_to]))
    end
    @programs = @programs.all
  end

  def show
    @stats = program_stats(@program)
  end

  def new
    @program = Program.new(program_params)

    render :layout => nil
  end

  def edit
    render :layout => nil
  end

  def create
    @program = Program.new(program_params)

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
    if !params[:program]
      return 400
    end

    respond_to do |format|
      if @program.authored_update(current_user, program_params)
        flash[:notice] = 'Program was successfully updated.'
        format.html { ajax_refresh }
      else
        flash[:error] = "There was an error updating the program"
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def import
  end

  def tooltip
    render :layout => '_tooltip', :locals => { :program => @program }
  end

  def sections
    @sections = @program.sections.includes(:controls => :implementing_controls)
    if params[:s]
      @sections = @sections.fulltext_search(params[:s])
    end
    @sections = allowed_objs(@sections.all.sort_by(&:slug_split_for_sort), :read)
    render :layout => nil, :locals => { :sections => @sections }
  end

  def controls
    @controls = @program.controls.includes(:implementing_controls)
    if params[:s]
      @controls = @controls.fulltext_search(params[:s])
    end
    @controls = allowed_objs(@controls.all.sort_by(&:slug_split_for_sort), :read)
    render :layout => nil, :locals => { :controls => @controls }
  end

  def section_controls
    if @program.company?
      @sections = @program.controls.includes(:implemented_controls => { :control_sections => :section }).map { |cc| cc.implemented_controls.map { |ic| ic.control_sections.map { |cs| cs.section } }.flatten }.flatten.uniq
    else
      @sections = @program.sections.includes(:controls => :implementing_controls).all
    end
    @sections.sort_by(&:slug_split_for_sort)
    @sections = allowed_objs(@sections, :read)
    render :layout => nil, :locals => { :sections => @sections }
  end

  def control_sections
    @controls = @program.controls.includes(:sections)
    if params[:s]
      @controls = @controls.fulltext_search(params[:s])
    end
    @controls = allowed_objs(@controls.all.sort_by(&:slug_split_for_sort), :read)
    render :layout => nil, :locals => { :controls => @controls }
  end

  def category_controls
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

  private

    def load_program
      @program = Program.find(params[:id])
    end

    def program_params
      program_params = params[:program] || {}
      if program_params[:type]
        program_params[:company] = (program_params.delete(:type) == 'company')
      end
      %w(start_date stop_date audit_start_date).each do |field|
        parse_date_param(program_params, field)
      end
      %w(kind audit_frequency audit_duration).each do |field|
        parse_option_param(program_params, field)
      end
      program_params
    end

end
