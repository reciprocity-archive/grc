module AuthorizationHelper
  # Roles
  def access_control_roles
    [:user, :superuser]
  end

  def allowed_objs(objects, ability)
    Authorization::allowed_objects(ability, @current_user, objects)
  end
  
  def check_risk_authorization(models)
    if current_user.can_manage_risk?
      models
    else
      models.delete('Risk')
    end
  end
end
