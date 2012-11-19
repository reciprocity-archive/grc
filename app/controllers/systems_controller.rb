# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# HandleSystems
class SystemsController < BaseObjectsController

  access_control :acl do
    allow :superuser

    actions :new, :create do
      allow :create, :create_system
    end

    allow :read, :read_system, :of => :system, :to => [:show,
                                                       :tooltip]

    actions :edit, :update do
      allow :update, :update_system, :of => :system
    end
  end

  layout 'dashboard'

  # TODO BASE OBJECTS
  # - use abstracted methods to handle 'index' cases

  def index
    @systems = System
    if params[:s].present?
      @systems = @systems.db_search(params[:s])
    end

    @systems = @systems.all

    if params[:as_subsystems_for].present?
      super_system_id = params[:as_subsystems_for].to_i
      if super_system_id.present?
        @systems = @systems.select { |s| s.id != super_system_id }
      end
    end

    render :json => @systems
  end

  private

    def delete_model_stats
      [ [ 'System Control', @system.system_controls.count ],
        [ 'System Section', @system.system_sections.count ]
      ]
    end

    def delete_relationship_stats
      [ [ 'Sub Systems', @system.sub_systems.count ],
        [ 'Super Systems', @system.super_systems.count ],
        [ 'Document', @system.documents.count ],
        [ 'Category', @system.categories.count ],
        [ 'Person', @system.people.count ]
      ]
    end

    def post_destroy_path
      programs_dash_path
    end

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
end
