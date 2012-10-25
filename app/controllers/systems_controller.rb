# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# HandleSystems
class SystemsController < ApplicationController
  include ApplicationHelper

  before_filter :load_system, :only => [:show,
                                         :edit,
                                         :tooltip,
                                         :update,
                                         :delete,
                                         :destroy]


  access_control :acl do
    allow :superuser

    actions :new, :create do
      allow :create, :create_system
    end

    actions :tooltip do
      allow :read, :read_system, :of => :system
    end

    actions :edit, :update do
      allow :update, :update_system, :of => :system
    end
  end

  layout 'dashboard'

  def index
    @systems = System
    if params[:s].present?
      @systems = @systems.db_search(params[:s])
    end
    render :json => @systems.all
  end

  def show
    @system = System.find(params[:id])
  end

  def new
    @system = System.new(system_params)

    render :layout => nil
  end

  def edit
    @system = System.find(params[:id])

    render :layout => nil
  end

  def create
    @system = System.new(system_params)

    respond_to do |format|
      if @system.save
        flash[:notice] = "Successfully created a new system."
        format.json do
          render :json => @system.as_json(:root => nil), :location => flow_system_path(@system)
        end
        format.html { redirect_to flow_system_path(@system) }
      else
        flash[:error] = "There was an error creating the system"
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    @system = System.find(params[:id])

    respond_to do |format|
      if @system.authored_update(current_user, system_params)
        flash[:notice] = "Successfully updated the system."
        format.json do
          render :json => @system.as_json(:root => nil), :location => flow_system_path(@system)
        end
        format.html { redirect_to flow_system_path(@system) }
      else
        flash[:error] = "There was an error updating the system"
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def delete
    @model_stats = []
    @relationship_stats = []
    @model_stats << [ 'System Control', @system.system_controls.count ]
    @model_stats << [ 'System Section', @system.system_sections.count ]
    @relationship_stats << [ 'Sub Systems', @system.sub_systems.count ]
    @relationship_stats << [ 'Super Systems', @system.super_systems.count ]
    @relationship_stats << [ 'Document', @system.documents.count ]
    @relationship_stats << [ 'Category', @system.categories.count ]
    @relationship_stats << [ 'Person', @system.people.count ]
    respond_to do |format|
      format.json { render :json => @system.as_json(:root => nil) }
      format.html do
        render :layout => nil, :template => 'shared/delete_confirm',
          :locals => { :model => @system, :url => flow_system_path(@system), :models => @model_stats, :relationships => @relationship_stats }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @system.destroy
        flash[:notice] = "System deleted"
        format.html { ajax_refresh }
      else
        flash[:error] = "Failed to delete system"
        format.html { ajax_refresh }
      end
    end
  end

  def tooltip
    @system = System.find(params[:id])
    render :layout => '_tooltip', :locals => { :system => @system }
  end

  private

    def system_params
      system_params = params[:system] || {}
      %w(type).each do |field|
        value = system_params.delete(field + '_id')
        if value.present?
          system_params[field] = Option.find(value)
        end
      end

      # Fixup legacy boolean
      if system_params[:type]
        system_params[:infrastructure] = system_params[:type].title == 'Infrastructure'
      else
        system_params[:infrastructure] = false
      end

      system_params
    end

    def load_system
      @system = System.find(params[:id])
    end
end
