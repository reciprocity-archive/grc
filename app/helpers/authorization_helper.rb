module AuthorizationHelper
  # Roles
  def access_control_roles
    [:superuser, :user]
  end

  def allowed_objs(objects, ability)
    Authorization::allowed_objects(ability, @current_user, objects)
  end
end
