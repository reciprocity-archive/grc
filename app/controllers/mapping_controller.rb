class MappingController < ApplicationController
  include ControlsHelper

  layout 'dashboard'
  respond_to :html, :json

  cache_sweeper :section_sweeper, :only => [:map_rcontrol, :map_ccontrol, :update]
  cache_sweeper :control_sweeper, :only => [:map_rcontrol, :map_ccontrol]

  def show
    @program = Program.find(params[:program_id])
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
        render :json => []
        return
      end
      ccontrol = Control.find(params[:ccontrol])

      rcontrol_slug = section.slug + "-" + ccontrol.slug
      rcontrol = Control.where(:slug => rcontrol_slug).first_or_initialize(
          :title => section.title,
          :slug => rcontrol_slug,
          :description => "Placeholder",
          #:directive => ccontrol.directive,
          :type => ccontrol.type,
          :kind => ccontrol.kind,
          :means => ccontrol.means,
          :start_date => ccontrol.start_date,
          :stop_date => ccontrol.stop_date,
          :url => ccontrol.url,
          :verify_frequency => ccontrol.verify_frequency,
          :documentation_description => ccontrol.documentation_description
        )
      rcontrol.directive = section.directive
      rcontrol.save

      rcontrol_id = rcontrol.id
      ControlControl.where(:implemented_control_id => rcontrol,
                            :control_id => ccontrol).first_or_create
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
      ControlSection.where(:section_id => section,
                            :control_id => rcontrol).first_or_create
      notice = notice + "Mapped regulation control. "
    end

    flash[:notice] = notice

    render :json => []
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

    render :json => []
  end

  def update
    section = Section.find(params[:section_id])
    section.na = params[:section]['na']
    section.notes = params[:section]['notes']
    section.save(:validate => false)

    flash[:notice] = "Saved"
    ajax_refresh
  end
end
