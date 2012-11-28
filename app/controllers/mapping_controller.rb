class MappingController < ApplicationController
  include ControlsHelper

  layout 'dashboard'
  respond_to :html, :json
  skip_after_filter :flash_to_headers, :only => [:buttons]

  cache_sweeper :section_sweeper, :only => [:map_rcontrol, :map_ccontrol, :update]
  cache_sweeper :control_sweeper, :only => [:map_rcontrol, :map_ccontrol]

  def show
    @program = Program.find(params[:program_id])
    @sections = @program.sections.with_controls
    @ccontrols = Control.joins(:program).where(Program.arel_table[:company].eq(true)).all.sort_by(&:slug_split_for_sort)
    @rcontrols = Control.where(:program_id => @program).all.sort_by(&:slug_split_for_sort)
  end

  def section_dialog
    @section = Section.find(params[:section_id])
    ccontrols = @section.consolidated_controls
    rcontrols = @section.controls
    if ccontrols.empty? && rcontrols.empty?
      render :partial => 'section_dialog_na', :locals => { :section => @section }
    else
      render :partial => 'section_dialog_controls',
             :locals => {
               :section => @section,
               :ccontrols => ccontrols,
               :rcontrols => rcontrols
             }
    end
  end

  def map_rcontrol
    rcontrol_id = params[:rcontrol]
    section = Section.find(params[:section])
    notice = ""

    if rcontrol_id.blank?
      if params[:u]
        flash[:error] = "I don't know how to unmap an indirect relationship"
        render :text => ''
        return
      end
      ccontrol = Control.find(params[:ccontrol])
      rcontrol = Control.new(
        :title => section.title,
        :slug => section.slug + "-" + ccontrol.slug,
        :description => "Placeholder",
        #:program => ccontrol.program,
        :type => ccontrol.type,
        :kind => ccontrol.kind,
        :means => ccontrol.means,
        :start_date => ccontrol.start_date,
        :stop_date => ccontrol.stop_date,
        :url => ccontrol.url,
        :verify_frequency => ccontrol.verify_frequency,
        :documentation_description => ccontrol.documentation_description
      )
      rcontrol.program = section.program
      rcontrol.save

      rcontrol_id = rcontrol.id
      ControlControl.create(:implemented_control => rcontrol,
                            :control => ccontrol)
      notice = notice + "Created regulation control #{rcontrol.slug}. "
    else
      rcontrol = Control.find(rcontrol_id)
    end

    if params[:u]
      ControlSection.where(:section_id => section.id,
                           :control_id => rcontrol.id).each {|r|
        r.destroy
      }
      notice = notice + "Unmapped regulation control. "
    else
      ControlSection.create(:section => section,
                            :control => rcontrol)
      notice = notice + "Mapped regulation control. "
    end

    flash[:notice] = notice

    render :text => ''
  end

  def map_ccontrol
    rcontrol = Control.find(params[:rcontrol])
    ccontrol = Control.find(params[:ccontrol])

    if params[:u]
      ControlControl.where(:implemented_control_id => rcontrol.id,
                           :control_id => ccontrol.id).each {|r|
        r.destroy
      }
      flash[:notice] = "Unmapped company control"
    else
      ControlControl.create(:implemented_control => rcontrol,
                            :control => ccontrol)
      flash[:notice] = "Mapped company control"
    end

    render :text => ''
  end

  def selected_control
    control = Control.find(params[:control_id])
    is_company = params[:control_type] == 'company'
    respond_with do |format|
      format.html do
        if is_company
          render :partial => 'selected_control', :locals => { :control => control, :control_type => 'ccontrol', :map_button_id => nil }
        else
          render :partial => 'selected_control', :locals => { :control => control, :control_type => 'rcontrol', :map_button_id => :cmap, :map_button_path => mapping_map_ccontrol_path }
        end
      end
    end
  end

  def selected_section
    section = Section.find(params[:section_id])
    respond_with do |format|
      format.html do
        render :partial => 'selected_section', :locals => { :section => section }
      end
    end
  end

  def update
    section = Section.find(params[:section_id])
    section.na = params[:section]['na']
    section.notes = params[:section]['notes']
    section.save

    flash[:notice] = "Saved"
    ajax_refresh
  end

  def buttons
    if !params[:rcontrol].blank?
      reg_exists =
        params[:section] && params[:rcontrol] &&
        ControlSection.exists?(:section_id => params[:section],
                               :control_id => params[:rcontrol])
    else
      reg_exists =
        params[:section] && params[:ccontrol] &&
        Control.joins(:implementing_controls).joins(:sections).
        exists?(:sections => {:id => params[:section]}, :implementing_controls_controls => {:id => params[:ccontrol]})
    end
    com_exists =
      params[:rcontrol] && params[:ccontrol] &&
      ControlControl.exists?(:implemented_control_id => params[:rcontrol],
                             :control_id => params[:ccontrol])
    respond_with do |format|
      format.json do
        render :json => [reg_exists, com_exists]
      end
    end
  end

  def find_sections
    @program = Program.find(params[:program_id])
    @search = params[:s]
    sections = @program.sections.with_controls

    unless @search.blank?
      sections = sections.fulltext_search(@search)
      @ttl = 120 # cache searches for less time so as not to fill up the cache
    end

    respond_with do |format|
      format.html do
        render :partial => 'section_list',
               :locals => { :sections => sections.all }
      end
    end
  end

  def find_controls
    @program = Program.find(params[:program_id])
    @search = params[:s]
    is_company = params[:control_type] == 'company'

    if is_company
      controls = Control.joins(:program).where(Program.arel_table[:company].eq(true))
    else
      controls = Control.where(:program_id => @program)
    end

    unless @search.blank?
      controls = controls.fulltext_search(@search)
      @ttl = 120 # cache searches for less time so as not to fill up the cache
    end

    respond_with do |format|
      format.html do
        render :partial => 'control_list_content',
               :locals => { :controls => controls.all, :control_type => params[:control_type] }
      end
    end
  end

  def create_ccontrol
    @control = Control.new(control_params)

    respond_to do |format|
      if @control.save
        flash[:notice] = "Successfully created a new company control"
        format.html { ajax_refresh }
      else
        flash[:error] = "There was an error creating the control."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def create_rcontrol
    @control = Control.new(control_params)

    respond_to do |format|
      if @control.save
        flash[:notice] = "Successfully created a new regulation control"
        format.html { ajax_refresh }
      else
        flash[:error] = "There was an error creating the control."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end
end
