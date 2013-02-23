# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class CyclesController < BaseObjectsController

  access_control :acl do
    allow :superuser

    actions :new, :create do
      allow :create, :create_cycle
    end

    actions :show, :tooltip do
      allow :read, :read_cycle, :of => :cycle
    end

    actions :edit, :update do
      allow :update, :update_cycle, :of => :cycle
    end
  end

  layout 'dashboard'

  no_base_action :index

  def new_object_path
  end

  private

    def cycle_params
      cycle_params = params[:cycle] || {}
      directive_id = cycle_params.delete(:directive_id)
      if directive_id.present?
        directive = Directive.where(:id => directive_id).first
        if directive.present?
          cycle_params[:directive] = directive
        end
      end
      parse_date_param(cycle_params, :start_at)
      parse_date_param(cycle_params, :end_at)
      cycle_params
    end

    def post_destroy_path
      flow_directive_path(@cycle.directive)
    end
end
