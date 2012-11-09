# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class CyclesController < ApplicationController
  before_filter :load_cycle, :only => [:show,
                                       :edit,
                                       :update,
                                       :delete,
                                       :destroy]

  access_control :acl do
    allow :superuser

    actions :new, :create do
      allow :create, :create_cycle
    end

    actions :show do
      allow :read, :read_cycle, :of => :cycle
    end

    actions :edit, :update do
      allow :update, :update_cycle, :of => :cycle
    end
  end

  layout 'dashboard'

  def show
  end

  def new
    @cycle = Cycle.new(cycle_params)

    render :layout => nil
  end

  def edit
    render :layout => nil
  end

  def create
    @cycle = Cycle.new(cycle_params)

    respond_to do |format|
      if @cycle.save
        flash[:notice] = "Successfully created a new cycle"
        format.html { redirect_to flow_cycle_path(@cycle) }
      else
        flash[:error] = @cycle.errors.full_messages
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    respond_to do |format|
      if @cycle.authored_update(current_user, cycle_params)
        flash[:notice] = "Successfully updated the cycle!"
        format.html { redirect_to flow_cycle_path(@cycle) }
      else
        flash[:error] = @cycle.errors.full_messages
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def delete
    @model_stats = []
    @relationship_stats = []

    respond_to do |format|
      format.json { render :json => @cycle.as_json(:root => nil) }
      format.html do
        render :layout => nil, :template => 'shared/delete_confirm',
          :locals => { :model => @cycle, :url => flow_cycle_path(@cycle), :models => @model_stats, :relationships => @relationship_stats }
      end
    end
  end

  def destroy
    @cycle.destroy
    flash[:notice] = "Cycle deleted"
    respond_to do |format|
      format.html { redirect_to flow_program_path(@cycle.program) }
      format.json { render :json => @cycle.as_json(:root => nil) }
    end
  end

  private
    def load_cycle
      @cycle = Cycle.find(params[:id])
    end

    def cycle_params
      cycle_params = params[:cycle] || {}
      program_id = cycle_params.delete(:program_id)
      if program_id.present?
        program = Program.where(:id => program_id).first
        if program.present?
          cycle_params[:program] = program
        end
      end
      parse_date_param(cycle_params, :start_at)
      cycle_params
    end
end
