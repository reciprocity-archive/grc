module AutofilterHelper
  # Filter Control Objectives by slug.
  #
  # This is used for the respective filtering widgets.  The widgets store
  # their state in the session.
  def filtered_control_objectives
    cos = ControlObjective.slugfilter(session[:slugfilter])
    if @regulation
      cos = cos.all(:regulation => @regulation)
    end
    cos
  end

  # Filter Controls by slug.
  #
  # This is used for the respective filtering widgets.  The widgets store
  # their state in the session.
  def filtered_controls
    controls = Control.slugfilter(session[:slugfilter])
    if @regulation
      controls = controls.all(:regulation => @regulation)
    end
    controls
  end
end
