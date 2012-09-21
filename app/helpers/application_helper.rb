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
end
