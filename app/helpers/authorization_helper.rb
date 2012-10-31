module AuthorizationHelper
  # Roles
  def access_control_roles
    [:superuser, :user]
  end

  def allowed_objs(objects, ability)
    objects.reduce([]) do |filtered, object|
      #@current_user.allowed?(ability, object) do
      object.allowed?(ability, @current_user) do
        filtered.append(object)
      end
      filtered
    end
  end
end
