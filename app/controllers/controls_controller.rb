# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle Controls
class ControlsController < ApplicationController
  include ApplicationHelper
  include ControlsHelper
  include AuthorizationHelper

  before_filter :load_control, :only => [:show,
                                         :edit,
                                         :tooltip,
                                         :update,
                                         :sections,
                                         :implemented_controls,
                                         :implementing_controls]


  access_control :acl do
    allow :superuser, :admin, :analyst

    actions :new, :create do
      allow :create_control
    end

    actions :edit, :update do
      allow :update_control, :of => :control
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

  def edit
    render :layout => nil
  end

  def show
  end

  def tooltip
    render :layout => nil
  end

  def new
    @control = Control.new(control_params)

    render :layout => nil
  end

  def create
    @control = Control.new(control_params)

    respond_to do |format|
      if @control.save
        flash[:notice] = "Successfully created a new control"
        format.json do
          render :json => @control.as_json(:root => nil)
        end
        format.html { redirect_to flow_control_path(@control) }
      else
        flash[:error] = "There was an error creating the control."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    respond_to do |format|
      if @control.authored_update(current_user, control_params)
        flash[:notice] = "Successfully updated the control!"
        format.json do
          render :json => @control.as_json(:root => nil)
        end
        format.html { redirect_to flow_control_path(@control) }
      else
        flash[:error] = "There was an error updating the control"
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def index
    @controls = allowed_objs(Control.all, :read)
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
      @controls = @controls.search(params[:s])
    end
    @controls.all.sort_by(&:slug_split_for_sort)
    render :action => 'controls', :layout => nil, :locals => { :controls => @controls, :prefix => 'Parent of' }
  end

  def implementing_controls
    @controls = @control.implementing_controls
    if params[:s]
      @controls = @controls.search(params[:s])
    end
    @controls.all.sort_by(&:slug_split_for_sort)
    render :action => 'controls', :layout => nil, :locals => { :controls => @controls, :prefix => 'Child of' }
  end

  private
    def load_control
      @control = Control.find(params[:id])
    end

    def control_params
      control_params = params[:control] || {}
      if control_params[:program_id]
        # TODO: Validate the user has access to add controls to the program
        control_params[:program] = Program.where(:id => control_params.delete(:program_id)).first
      end
      %w(type kind means).each do |field|
        value_id = control_params.delete(field + '_id')
        if value_id.present?
          control_params[field] = Option.find(value_id)
        end
      end
      %w(category).each do |field|
        value_ids = control_params.delete(field + '_ids')
        values = []
        if value_ids.respond_to?(:each)
          value_ids.each do |value_id|
            values.push(Category.where(:id => value_id).first)
          end
          control_params[field.pluralize] = values
        end
      end
      control_params
    end
end
