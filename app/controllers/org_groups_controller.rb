# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle Org Groups
class OrgGroupsController < ApplicationController
  include ApplicationHelper

  before_filter :load_org_group, :only => [:show,
                                         :edit,
                                         :update,
                                         :tooltip,
                                         :delete,
                                         :destroy]

  access_control :acl do
    # FIXME: Implement real authorization

    allow :superuser

    actions :index do
      allow :read, :read_org_group
    end

    actions :new, :create do
      allow :create, :create_org_group
    end

    actions :edit, :update do
      allow :update, :update_org_group, :of => :org_group
    end

    actions :show, :tooltip do
      allow :read, :read_org_group, :of => :org_group
    end

  end

  layout 'dashboard'

  def index
    @org_groups = OrgGroup
    if params[:s]
      @org_groups = @org_groups.db_search(params[:s])
    end
    @org_groups = allowed_objs(@org_groups.all, :read)

    render :json => @org_groups
  end

  def show
  end

  def new
    @org_group = OrgGroup.new(org_group_params)
    render :layout => nil
  end

  def edit
    render :layout => nil
  end

  def create
    @org_group = OrgGroup.new(org_group_params)

    respond_to do |format|
      if @org_group.save
        flash[:notice] = "Successfully created a new org group."
        format.json do
          render :json => @org_group.as_json(:root => nil), :location => flow_org_group_path(@org_group)
        end
        format.html { redirect_to flow_org_group_path(@org_group) }
      else
        flash[:error] = "There was an error creating the org group."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    if !params[:org_group]
      return 400
    end

    respond_to do |format|
      if @org_group.authored_update(current_user, org_group_params)
        flash[:notice] = "Successfully updated the org group."
        format.json { render :json => @org_group.as_json(:root => nil), :location => flow_org_group_path(@org_group) }
        format.html { redirect_to flow_org_group_path(@org_group) }
      else
        flash[:error] = "There was an error updating the org group."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def delete
    @model_stats = []
    @relationship_stats = []

    # FIXME: Automatically generate relationship stats

    respond_to do |format|
      format.json { render :json => @org_group.as_json(:root => nil) }
      format.html do
        render :layout => nil, :template => 'shared/delete_confirm',
          :locals => { :model => @org_group, :url => flow_org_group_path(@org_group), :models => @model_stats, :relationships => @relationship_stats }
      end
    end
  end

  def destroy
    @org_group.destroy
    flash[:notice] = "org_group deleted"
    respond_to do |format|
      format.html { redirect_to programs_dash_path }
      format.json { render :json => @org_group.as_json(:root => nil), :location => programs_dash_path }
    end
  end

  def tooltip
    render :layout => '_tooltip', :locals => { :org_group => @org_group }
  end

  private

    def load_org_group
      @org_group = OrgGroup.find(params[:id])
    end

    def org_group_params
      org_group_params = params[:org_group] || {}
      %w(type).each do |field|
        parse_option_param(org_group_params, field)
      end
      %w(start_date stop_date).each do |field|
        parse_date_param(product_params, field)
      end
      org_group_params
    end
end
