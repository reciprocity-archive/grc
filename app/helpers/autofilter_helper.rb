module AutofilterHelper
  def filtered_control_objectives
    ControlObjective.slugfilter(session[:slugfilter])
  end

  def filtered_controls
    Control.slugfilter(session[:slugfilter])
  end
end
