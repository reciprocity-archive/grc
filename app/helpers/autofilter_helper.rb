module AutofilterHelper
  # Filter Sections by slug.
  #
  # This is used for the respective filtering widgets.  The widgets store
  # their state in the session.
  def filtered_sections
    secs = Section.slugfilter(session[:slugfilter])
    if @program
      secs = secs.where(:program_id => @program)
    end
    secs
  end

  # Filter Controls by slug.
  #
  # This is used for the respective filtering widgets.  The widgets store
  # their state in the session.
  def filtered_controls
    controls = Control.slugfilter(session[:slugfilter])
    if @program
      controls = controls.where(:program_id => @program)
    end
    controls
  end
end
