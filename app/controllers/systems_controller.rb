# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

require 'csv'

# HandleSystems
class SystemsController < BaseObjectsController

#  access_control :acl do
#    allow :superuser
#
#    actions :new, :create, :import do
#      allow :create, :create_system
#    end
#
#    allow :read, :read_system, :of => :system, :to => [:show,
#                                                       :tooltip]
#
#    actions :edit, :update do
#      allow :update, :update_system, :of => :system
#    end
#  end
  
  before_filter :check_risk_authorization, :only => [:import]

  layout 'dashboard'

  # TODO BASE OBJECTS
  # - use abstracted methods to handle 'index' cases

  def index
    @systems = System
    if params[:is_biz_process] == 'false'
      @systems = @systems.where(:is_biz_process => false)
    elsif params[:is_biz_process] == 'true'
      @systems = @systems.where(:is_biz_process => true)
    end
    if params[:s].present?
      @systems = @systems.db_search(params[:s])
    end

    if params[:parent_id].present?
      @systems = @systems.joins(:super_system_systems).where(:system_systems => { :parent_id => params[:parent_id] })
    end

    @systems = @systems.all

    if params[:as_subsystems_for].present?
      super_system_id = params[:as_subsystems_for].to_i
      if super_system_id.present?
        @systems = @systems.select { |s| s.id != super_system_id }
      end
    end

    respond_to do |format|
      format.html do
        if params[:quick]
          render :partial => 'quick', :locals => { :quick_result => params[:qr]}
        end
      end
      format.json do
        render :json => @systems, :methods => :description_inline
      end
    end
  end

  def export
    @is_biz_process = params[:is_biz_process] == '1' ? '1' : nil

    respond_to do |format|
      format.html do
        render :layout => 'export_modal'
      end
      format.csv do
        systems = System
        if @is_biz_process
          systems = systems.where(:is_biz_process => true)
        else
          systems = systems.where(:is_biz_process => false)
        end

        filename = "#{@is_biz_process ? "PROCESSES" : "SYSTEMS"}.csv"
        handle_converter_csv_export(filename, systems.all, SystemsConverter, :is_biz_process => @is_biz_process)
      end
    end
  end

  def import
    @is_biz_process = params[:is_biz_process] == '1' ? '1' : nil

    handle_csv_import(SystemsConverter, :is_biz_process => @is_biz_process) do |converter|
      flash[:notice] = "<i class='grcicon-ok'></i> #{converter.created_objects.size + converter.updated_objects.size} #{@is_biz_process ? 'Processes' : 'Systems'} are Imported Successfully!".html_safe
      keep_flash_after_import
      render :json => { :location => programs_dash_path }
    end
  end

  def new_object_title
    if object.present? && object.is_biz_process?
      "Process"
    else
      "System"
    end
  end

  def new_object_path
    if object.present?
      if object.is_biz_process?
        new_flow_system_path(:'system[is_biz_process]' => true)
      else
        new_flow_system_path(:'system[is_biz_process]' => false)
      end
    else
      new_flow_system_path
    end
  end

  private

    def object_as_json(args={})
      object.as_json args
    end

    def show_set_page_types
      super
      @page_subtype = object.is_biz_process? ? 'processes' : 'systems'
    end

    def delete_model_stats
      [ [ 'System Control', @system.system_controls.count ],
        [ 'System Section', @system.system_sections.count ],
        [ 'Response', @system.responses.count ]
      ]
    end

    def extra_delete_relationship_stats
      [ [ 'Sub Systems', @system.sub_systems.count ],
        [ 'Super Systems', @system.super_systems.count ],
      ]
    end

    def post_destroy_path
      programs_dash_path
    end

    def system_params
      system_params = params[:system] || {}
      %w(type).each do |field|
        parse_option_param(system_params, field)
      end

      %w(start_date stop_date).each do |field|
        parse_date_param(system_params, field)
      end

      # Fixup legacy boolean
      if system_params[:type]
        system_params[:infrastructure] = system_params[:type].title == 'Infrastructure'
      else
        system_params[:infrastructure] = false
      end

      system_params
    end
end
