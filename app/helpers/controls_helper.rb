module ControlsHelper
  def control_params
    control_params = params[:control] || {}
    if control_params[:directive_id]
      # TODO: Validate the user has access to add controls to the directive
      control_params[:directive] = Directive.where(:id => control_params.delete(:directive_id)).first
    end
    %w(type kind means verify_frequency).each do |field|
      parse_option_param(control_params, field)
    end
    %w(start_date stop_date).each do |field|
      parse_date_param(control_params, field)
    end
    %w(category assertion).each do |field|
      value_ids = control_params.delete(field + '_ids')
      values = []
      if value_ids.respond_to?(:each)
        value_ids.each do |value_id|
          values.push(Category.where(:id => value_id).first)
        end
        control_params[field.pluralize] = values
      end
    end
    control_params
  end
end
