module AutofilterHelper
  # Filter Control Objectives by slug.
  #
  # This is used for the respective filtering widgets.  The widgets store
  # their state in the session.
  def filtered_control_objectives
    ControlObjective.slugfilter(session[:slugfilter])
  end

  # Filter Controls by slug.
  #
  # This is used for the respective filtering widgets.  The widgets store
  # their state in the session.
  def filtered_controls
    Control.slugfilter(session[:slugfilter])
  end
end
