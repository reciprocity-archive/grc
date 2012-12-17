# Handle PBC Lists
class PbcListsController < BaseObjectsController

  access_control :acl do
    # FIXME: Implement real authorization

    allow :superuser

    actions :index do
      allow :read, :read_pbc_list
    end

    actions :new, :create do
      allow :create, :create_pbc_list
    end

    actions :edit, :update do
      allow :update, :update_pbc_list, :of => :pbc_list
    end

    actions :show, :tooltip do
      allow :read, :read_pbc_list, :of => :pbc_list
    end

  end

  layout 'dashboard'

  private

    def post_destroy_path
      flow_cycle_path(object.audit_cycle_id)
    end

    def pbc_list_params
      pbc_list_params = params[:pbc_list] || {}

      audit_cycle_id = pbc_list_params.delete(:audit_cycle_id)
      if audit_cycle_id.present?
        audit_cycle = Cycle.where(:id => audit_cycle_id).first
        if audit_cycle.present?
          pbc_list_params[:audit_cycle] = audit_cycle
        end
      end
      #%w(type).each do |field|
      #  parse_option_param(pbc_list_params, field)
      #end
      %w(list_import_date).each do |field|
        parse_date_param(pbc_list_params, field)
      end
      pbc_list_params
    end

    def delete_model_stats
      [
        [ 'Request', @pbc_list.requests.count ]
      ]
    end
end
