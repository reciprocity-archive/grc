module AuthorizationHelper
  # Roles
  def access_control_roles
    [:user, :admin, :risk, :admin_risk, :no_access]
  end

  def allowed_objs(objects, ability)
    objects
    #Authorization::allowed_objects(ability, @current_user, objects)
  end

  def check_model_risk_authorization(models)
    if current_user.can_manage_risk?
      models
    else
      models.delete('Risk')
    end
  end
  
  def check_risk_authorization
    render_unauthorized unless current_user.can_manage_risk?
  end
  
  def check_admin_authorization
    render_unauthorized unless current_user.can_admin?
  end
  
  def is_risky_type?(string)
    string == 'Risk' || string == 'risk' || string == 'RiskyAttribute' || string == 'risky_attribute'
  end
end
