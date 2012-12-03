# Handle RiskyAttributes
class RiskyAttributesController < BusinessObjectsController

  access_control :acl do
    # FIXME: Implement real authorization

    allow :superuser

    actions :index do
      allow :read, :read_risky_attribute
    end

    actions :new, :create do
      allow :create, :create_risky_attribute
    end

    actions :edit, :update do
      allow :update, :update_risky_attribute, :of => :risky_attribute
    end

    actions :show, :tooltip do
      allow :read, :read_risky_attribute, :of => :risky_attribute
    end

  end

  layout 'dashboard'

  private

    def risky_attribute_params
      risky_attribute_params = params[:risky_attribute] || {}
      %w(type).each do |field|
        parse_option_param(risky_attribute_params, field)
      end
      %w(start_date stop_date).each do |field|
        parse_date_param(risky_attribute_params, field)
      end
      risky_attribute_params
    end
end
