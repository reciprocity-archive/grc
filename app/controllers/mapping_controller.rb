class MappingController < ApplicationController
  layout 'dashboard'
  respond_to :html, :json

  def show
    @program = Program.find(params[:program_id])
    @sections = @program.sections
    @ccontrols = Control.joins(:program).where(Program.arel_table[:company].eq(true))
    @rcontrols = Control.where(:program_id => @program)
  end

  def section_tooltip
    @section = Section.find(params[:section_id])
    render :layout => nil
  end

  def map_rcontrol
    if params[:u]
      ControlSection.where(:section_id => params[:section],
                           :control_id => params[:rcontrol]).each {|r|
        r.destroy
      }
    else
      ControlSection.create(:section_id => params[:section],
                            :control_id => params[:rcontrol])
    end

    render :js => 'update_map_buttons();'
  end

  def map_ccontrol
    if params[:u]
      ControlControl.where(:implemented_control_id => params[:rcontrol],
                           :control_id => params[:ccontrol]).each {|r|
        r.destroy
      }
    else
      ControlControl.create(:implemented_control_id => params[:rcontrol],
                            :control_id => params[:ccontrol])
    end

    render :js => 'update_map_buttons();'
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

  def buttons
    reg_exists =
      params[:section] && params[:rcontrol] && 
      ControlSection.exists?(:section_id => params[:section],
                             :control_id => params[:rcontrol])
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
    sections = @program.sections
    if params[:s]
      sections = sections.search(params[:s])
    end

    respond_with do |format|
      format.html do
        render :partial => 'section_list_content',
               :locals => { :sections => sections.all }
      end
    end
  end

  def find_controls
    @program = Program.find(params[:program_id])
    is_company = params[:control_type] == 'company'

    if is_company
      controls = Control.joins(:program).where(Program.arel_table[:company].eq(true))
    else
      controls = Control.where(:program_id => @program)
    end

    if params[:s]
      controls = controls.search(params[:s])
    end

    respond_with do |format|
      format.html do
        render :partial => 'control_list_content',
               :locals => { :controls => controls.all, :control_type => params[:control_type] }
      end
    end
  end
end
