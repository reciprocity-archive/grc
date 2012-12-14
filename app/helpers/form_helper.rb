module FormHelper

  # Simple helper for repetitive form error spans
  def error_messages_inline(f, field_name)
    capture_haml do
      haml_tag :span, :class => 'help-inline' do
        f.object.errors[field_name].each do |error|
          haml_tag :span do
            haml_concat "#{error}"
          end
        end
      end
    end
  end

  def error_class(f, field_name)
    if !f.object.errors.empty?
      if f.object.errors[field_name].empty?
        'field-success'
      else
        'field-failure'
      end
    end
  end

  def member_error_messages_inline(o)
    capture_haml do
      if !o.errors.empty?
        haml_tag :span, :class => 'help-inline' do
          o.errors.each do |_, error|
            haml_tag :span do
              haml_concat "#{error}"
            end
          end
        end
      end
    end
  end

  def member_error_class(o)
    if o.changed?
      if !o.errors.empty?
        'member-failure'
      else
        'member-success'
      end
    end
  end

  def wrapped_text_area(f, span_class, name, *args)
    wrapped_input(:text_area, f, span_class, name, *args)
  end

  def wrapped_text_field(f, span_class, name, *args)
    wrapped_input(:text_field, f, span_class, name, *args)
  end

  def wrapped_date_field(f, span_class, name, options=nil)
    options ||= {}
    if !options.has_key?(:value) && f.object.respond_to?(name)
      value = f.object.send(name)
      options[:value] = value && value.strftime('%m/%d/%Y')
    end
    options[:'data-toggle'] ||= 'datepicker'
    wrapped_input(:text_field, f, span_class, name, options)
  end

  def wrapped_select(f, span_class, name, choices, options={}, html_options={})
    label_name = options.delete(:label_name)

    input_options = {}
    input_options[:class] = ['span12', options[:class]]

    classes = [span_class, error_class(f, name)]

    content_tag :div, :class => classes.compact do
      f.label(name, label_name) +
        f.select(name, choices, options, html_options.merge(input_options)) +
        error_messages_inline(f, name)
    end
  end

  # Generates HTML according to this structure:
  # %div{ :class => span_class }{ :class => error_class(...) }
  #   %label{ :for => 'unique-input-id' }=label_name
  #   %input{ :id => 'unique-input-id', :type => ..., :placeholder => ... }
  #   %span.help-inline=error_messages_inline(...)
  def wrapped_input(builder_name, f, span_class, name, *args)
    options = args.extract_options!

    label_name = options.delete(:label_name)
    wrapper_div_class = options.delete(:wrapper_div_class)

    input_options = {}
    input_options[:class] = ['span12', options[:class]]
    if !f.object.respond_to?(name)
      input_options[:value] ||= nil
    end

    classes = [span_class, error_class(f, name)]

    if wrapper_div_class.present?
      content_tag :div, :class => classes.compact do
        concat f.label(name, label_name)
        concat(content_tag(:div, :class => wrapper_div_class) do
          f.send(builder_name, name, *(args << options.merge(input_options))) +
          error_messages_inline(f, name)
        end)
      end
    else
      content_tag :div, :class => classes.compact do
        f.label(name, label_name) +
          f.send(builder_name, name, *(args << options.merge(input_options))) +
          error_messages_inline(f, name)
      end
    end
  end

  def parse_date_param(params, field)
    if params[field].present? && params[field].respond_to?(:match) &&
        params[field].match(/\d{1,2}\/\d{1,2}\/\d{4}/)
      params[field] = Date.strptime(params[field], '%m/%d/%Y').to_time_in_current_zone
    end
  end

  def parse_option_param(params, field)
    field_key = field + '_id'
    if params.has_key?(field_key)
      value_id = params.delete(field_key)
      if value_id.present?
        params[field] = Option.find(value_id)
      else
        params[field] = nil
      end
    end
  end
end
