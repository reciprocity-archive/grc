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
end
