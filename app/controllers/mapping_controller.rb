class MappingController < ApplicationController
  layout 'dashboard'
  respond_to :html, :json

  def show
    @program = Program.find(params[:program_id])
    @sections = @program.sections
    @ccontrols = Control.joins(:program).where(Program.arel_table[:company].eq(true))
    @rcontrols = Control.joins(:program).where(Program.arel_table[:company].eq(false))
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
        render :partial => 'selected_control', :locals => { :control => control, :control_type => (is_company ? 'ccontrol' : 'rcontrol') }
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
end
