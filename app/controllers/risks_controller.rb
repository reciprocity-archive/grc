# Handle Risks
class RisksController < BaseObjectsController

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

  def index
    @risks = Risk
    if params[:s].present?
      @risks = @risks.db_search(params[:s])
    end

    @risks = @risks.all

    respond_to do |format|
      format.html do
        if params[:quick]
          render :partial => 'quick'
        end
      end
      format.json do
        render :json => @risks
      end
    end
  end

  private

    def risk_params
      risk_params = params[:risk] || {}
      %w(start_date stop_date).each do |field|
        parse_date_param(risk_params, field)
      end
      risk_params
    end
end
