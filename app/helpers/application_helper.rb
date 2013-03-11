module ApplicationHelper
  # Shorthand humanized text for admin pages
  def pat(sym)
    sym.to_s.humanize
  end

  # Default time display (localize at some point)
  def display_time(time)
    time.strftime("%Y-%m-%d %H:%M") rescue "-"
  end

  #:nocov:
  # FIXME: No obvious way to sanely test this.
  # Use instead of 'yield :name' or 'content_for(:name)' in layouts for partials.
  # References:
  #   http://mikemayo.org/2012/rendering-a-collection-of-partials-with-content_for
  #   https://gist.github.com/rails/rails/pull/4226
  def yield_content!(name)
    view_flow.content.delete(name)
  end
  #:nocov:

  #:nocov:
  # FIXME: Used only by evidence_controller, but we don't want to get rid of
  # evidence controller since we're using it for reference.
  # Filter Systems by slug and/or the program of their attached controls.
  #
  # This is used for the respective filtering widgets.  The widgets store
  # their state in the session.
  def filter_systems(collection)
    control_search = {}
    unless session[:slugfilter].blank?
      control_search[:slug.like] = "#{session[:slugfilter]}%"
    end

    if session[:program_id]
      @program = Program.find(session[:program_id])
      control_search[:program_id] = @program
    end

    return collection if control_search.empty?
    return collection.
      joins(:system_controls => :control).
      where(:system_controls => {:controls => control_search})
  end
  #:nocov:

  def has_feature?(feature)
    @_features[feature]
  end

  # Convert an object to a hash to be used as HAML attributes.
  #
  # To get a hash of all object attributes use:
  #
  #   html_data_attributes(object, "data-filter-")
  #
  # Use attribute_options array to get only required attributes.
  # You can also specify method names and/or chain multiple methods.
  #
  #   html_data_attributes(object, "data-filter-", [ "status", ["myname", "method_name"], ["type", "type.display_name"] ])
  #
  # [
  #   "status", - will call on status on given object
  #   ["myname", "method_name"], - will call method_name and name attribute in resulting hash myname
  #   ["type", "type.display_name"] - if second element contains a dot it will assume it's a attribute/method chain (e.g. object.type.display_name)
  # ]
  def html_data_attributes(object, prefix, attribute_options = [])
    result = {}

    if attribute_options.present?
      attribute_options.each do |attribute|
        if attribute.is_a? Array
          key = attribute[0]
          methods = attribute[1].split(".")

          begin
            value = nil
            methods.each do |method|
              if value.blank?
                value = object.send(method)
                break if value.nil?
              else
                value = value.send(method)
              end
            end
          rescue
            # just ignore it
          end

          value = "" if value.nil?
        else
          key = attribute
          value = object.send(key)
        end

        result["#{prefix}#{key}"] = value
      end
    else
      object.attributes.each do |key, value|
        result["#{prefix}#{key}"] = value
      end
    end

    result
  end

  # Bad Dan
  def control_assessment_button_class(bit)
    if bit == false
      'btn-warning'
    elsif bit == true
      'btn-success'
    else
      ''
    end
  end

  def control_assessment_button_icon(bit)
    if bit == false
      'grcicon-x-white'
    elsif bit == true
      'grcicon-check-white'
    else
      'grcicon-blank'
    end
  end

  def request_type_icon(type_name)
    case type_name
    when 'Documentation' then
      'grcicon-document'
    when 'Population Sample' then
      'grcicon-populationsample'
    when 'Interview' then
      'grcicon-calendar'
    else
      'grcicon-document'
    end
  end

  def request_type_count(requests, type_name)
    case type_name
    when 'Documentation' then
      requests.count { |r| r.type_id.blank? || r.type_id == 1 }
    when 'Population Sample' then
      requests.count { |r| r.type_id == 2 }
    when 'Interview' then
      requests.count { |r| r.type_id == 3 }
    end
  end

  def sorted_requests_with_control_assessments(requests)
    requests.
      group_by(&:control_assessment_id).
      map do |id, requests|
        [id, requests.first.control_assessment, requests]
      end.
      sort_by do |_, control_assessment, _|
        key = (control_assessment.nil? || control_assessment.control.nil?) ? '' : control_assessment.control.slug
        # Magical sort respecting numbers
        key = key.split(/(\d+)/).map { |s| [s.to_i, s] }
        # No-controls go last instead of first.
        if key.empty? then key = [[+1.0/0.0, '']] end
        key
      end
  end

  def days_ago_in_words(from_date)
    distance_in_days = (from_date.to_date - Time.zone.now.to_date).abs.to_i
    if distance_in_days == 0
      "today"
    else
      pluralize(distance_in_days, "day")
    end
  end

  def all_models
    models = ActiveRecord::Base.connection.tables.collect{|t| t.underscore.singularize}
    models.delete("schema_migration")
    models.delete("version")
    models.delete("relationship_type")
    models.each do |model_name|
      model = model_name.camelize.constantize
      yield model
    end
  end

  # Treat content as HTML and pack it accordingly.
  # If a block is passed, capture and use as a prefix.
  # Be careful what you pass as content!
  def display_as_html(content, &block)
    content = content.presence || ""
    if content !~ /<\w+[^>]>/
      content = content.gsub("\n", "<br />")
    end
    content_tag :div, :class => "rtf" do
      if block_given?
        concat(capture(&block))
      end
      concat(content.html_safe)
    end
  end

  def render_html_or_json_array(objs)
    respond_to do |format|
      format.html do
        render
      end
      format.json do
        if params[:full]
          render :json => objs
        else
          render :json => objs.map {|o| o.id }
        end
      end
    end
  end

end
