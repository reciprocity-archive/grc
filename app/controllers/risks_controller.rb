# Handle Risks
class RisksController < BusinessObjectsController

  access_control :acl do
    # FIXME: Implement real authorization

    allow :superuser

    actions :index do
      allow :read, :read_risk
    end

    actions :new, :create do
      allow :create, :create_risk
    end

    actions :edit, :update do
      allow :update, :update_risk, :of => :risk
    end

    actions :show, :tooltip do
      allow :read, :read_risk, :of => :risk
    end

  end

  layout 'dashboard'

  private

    def risk_params
      risk_params = params[:risk] || {}
      %w(type).each do |field|
        parse_option_param(risk_params, field)
      end
      %w(start_date stop_date).each do |field|
        parse_date_param(risk_params, field)
      end
      risk_params
    end
end
