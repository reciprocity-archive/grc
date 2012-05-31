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
  end

  def map_ccontrol
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
end
