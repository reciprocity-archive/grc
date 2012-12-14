# Handle PBC Lists
class RequestsController < BaseObjectsController

  access_control :acl do
    # FIXME: Implement real authorization

    allow :superuser

    actions :index do
      allow :read, :read_request
    end

    actions :new, :create do
      allow :create, :create_request
    end

    actions :edit, :update do
      allow :update, :update_request, :of => :request
    end

    actions :show, :tooltip do
      allow :read, :read_request, :of => :request
    end

  end

  layout 'dashboard'

  private

    def object_path
      flow_pbc_list_path(object.pbc_list_id)
    end

    def pbc_list_params
      pbc_list_params = params[:pbc_list] || {}
      #%w(type).each do |field|
      #  parse_option_param(pbc_list_params, field)
      #end
      #%w(list_import_date).each do |field|
      #  parse_date_param(pbc_list_params, field)
      #end
      pbc_list_params
    end
end
