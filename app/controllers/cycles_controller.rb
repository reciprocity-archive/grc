# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class CyclesController < BaseObjectsController

#  access_control :acl do
#    allow :superuser
#
#    actions :new, :create do
#      allow :create, :create_cycle
#    end
#
#    actions :show, :tooltip do
#      allow :read, :read_cycle, :of => :cycle
#    end
#
#    actions :edit, :update do
#      allow :update, :update_cycle, :of => :cycle
#    end
#  end

  layout 'dashboard'

  no_base_action :index

  def new_object_path
  end

  private

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
      parse_date_param(cycle_params, :end_at)
      parse_date_param(cycle_params, :report_due_at)
      cycle_params
    end

    def post_destroy_path
      flow_program_path(@cycle.program)
    end
end
