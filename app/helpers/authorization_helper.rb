module AuthorizationHelper
  # Roles
  def access_control_roles
    [:superuser, :user]
  end

  def allowed_objs(objects, ability)
    @current_user.person.objects_via_ability(objects, ability)
  end
end
