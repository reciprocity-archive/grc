# Handle projects
class ProjectsController < BusinessObjectsController

  access_control :acl do
    # FIXME: Implement real authorization

    allow :superuser

    actions :new, :create do
      allow :create, :create_project
    end

    actions :edit, :update do
      allow :update, :update_project, :of => :project
    end

    actions :show, :tooltip do
      allow :read, :read_project, :of => :project
    end

  end

  layout 'dashboard'

  private

    def project_params
      project_params = params[:project] || {}
      %w(type).each do |field|
        parse_option_param(project_params, field)
      end
      %w(start_date stop_date).each do |field|
        parse_date_param(project_params, field)
      end
      project_params
    end
end
