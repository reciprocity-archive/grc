# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle Controls
class ControlsController < BaseObjectsController
  include ControlsHelper
  include AuthorizationHelper

  before_filter :load_control, :only => [:sections,
                                         :implemented_controls,
                                         :implementing_controls,
                                         :systems,
                                         :risks]

  cache_sweeper :control_sweeper, :only => [:create, :update, :destroy]

  access_control :acl do
    allow :superuser

    actions :new, :create do
      allow :create, :create_control
    end

    actions :edit, :update do
      allow :update, :update_control, :of => :control
    end

    actions :show, :tooltip do
      allow :read, :read_control, :of => :control
    end

    actions :index do
      allow :read, :read_control
    end

    actions :sections, :implemented_controls, :implementing_controls do
      allow :read, :read_control, :of => :control
    end
  end

  layout 'dashboard'

  def index
    @controls = Control
    if params[:s].present?
      @controls = @controls.fulltext_search(params[:s])
    end
    if params[:company].present?
      @controls = @controls.joins(:program).where(Program.arel_table[:company].eq(true))
    end
    @controls = allowed_objs(@controls.all, :read)

    if params[:list_select].present?
      render :partial => 'list_select', :layout => 'layouts/list_select_modal', :locals => {}
    elsif params[:quick]
      render :partial => 'quick', :locals => { :quick_result => params[:qr]}
    else
      render :json => @controls
    end
  end

  def sections
    @sections =
      @control.sections.all +
      @control.implemented_controls.includes(:sections).map(&:sections).flatten
    @sections = allowed_objs(@sections, :read)
    @sections.sort_by(&:slug_split_for_sort)
    render :layout => nil, :locals => { :sections => @sections }
  end

  def implemented_controls
    @controls = @control.implemented_controls
    if params[:s]
      @controls = @controls.fulltext_search(params[:s])
    end
    @controls.all.sort_by(&:slug_split_for_sort)
    respond_to do |format|
      format.html do
        render :action => 'controls', :layout => nil, :locals => { :controls => @controls, :prefix => 'Parent of' }
      end
      format.json do
        render :json => @controls, :methods => :implemented_controls
      end
    end
  end

  def implementing_controls
    @controls = @control.implementing_controls
    if params[:s]
      @controls = @controls.fulltext_search(params[:s])
    end
    @controls.all.sort_by(&:slug_split_for_sort)
    render :action => 'controls', :layout => nil, :locals => { :controls => @controls, :prefix => 'Child of' }
  end

  def systems
    @systems = @control.systems
    if params[:s]
      @systems = @systems.fulltext_search(params[:s])
    end
    @systems = @systems.all

    render :action => 'systems', :layout => nil, :locals => { :systems => @systems, :control => @control }
  end

  def risks
    @risks = @control.risks
    if params[:s]
      @risks = @risks.fulltext_search(params[:s])
    end
    @risks = @risks.all

    render :action => 'risks', :layout => nil, :locals => { :risks => @risks, :control => @control }
  end

  private

    def load_control
      @control = Control.find(params[:id])
    end

    def delete_model_stats
      [ [ 'System Control', @control.system_controls.count ]
      ]
    end

    def extra_delete_relationship_stats
      [ [ 'Section', @control.control_sections.count ],
        [ 'Implemented Control', @control.implemented_controls.count ],
        [ 'Implementing Control', @control.implementing_controls.count ],
      ]
    end

    def post_destroy_path
      flow_program_path(@control.program)
    end
end
