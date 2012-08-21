module AuthorizationHelper
  def allowed_objs(objects, ability)
    # FIXME: Until we audit all of the controllers/roles
    # to determine object visibility, allow all objects to
    # be seen for all abilities.
    objects
    #objects.reduce([]) do |filtered, object|
    #  object.allowed?(ability, @current_user) do
    #    filtered.append(object)
    #  end
    #  filtered
    #end
  end

  def self.included(model)
    model.extend(ClassMethods)
  end

  module ClassMethods
    def crud_acls(model)
      model_name = model.table_name.singularize
      access_control :crud_acl do
        allow :superuser, :admin, :analyst

        actions :new, :create do
          allow 'create_' + model_name
        end

        actions :edit, :update do
          allow 'update_' + model_name, :of => :control
        end

        actions :show, :tooltip do
          allow 'read_' + model_name, :of => :control
        end

        actions :index do
          allow 'read_' + model_name
        end

        actions :sections, :implemented_controls, :implementing_controls do
          allow 'read_' + model_name, :of => :control
        end
      end
    end
  end
end
