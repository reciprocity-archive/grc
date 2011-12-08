module ApplicationHelper
  ADMIN_MODULES = %w(accounts biz_processes business_areas control_objectives controls documents document_descriptors regulations people systems)
  WORKFLOW_MODULES = %w(dashboard evidence testing testreport) 

  class ProjectModule
    attr_accessor :name
    attr_accessor :path
    def initialize(name, path)
      @name = name
      @path = path
    end
  end

  # The set of modules shown as tabs on the main application page (aka workflow pages)
  def project_modules
    WORKFLOW_MODULES.map { |id| ProjectModule.new(id.humanize, url_for({:controller => "/" + id, :only_path => true})) }
  end

  # The set of modules shown as tabs on the admin application page (aka admin pages)
  def admin_project_modules
    ADMIN_MODULES.map { |id| ProjectModule.new(id.humanize, url_for({:controller => "/admin/" + id, :only_path => true})) }
  end

  # Roles
  def access_control_roles
    [:admin, :analyst, :guest]
  end

  # Filter SystemControl relationship objects by slug and/or regulation.
  #
  # This is used for the respective filtering widgets.  The widgets store
  # their state in the session.
  def filter_system_controls(collection)
    collection = collection.slugfilter(session[:slugfilter])
    if session[:regulation_id]
      @regulation = Regulation.get(session[:regulation_id])
      collection = collection.all({:control => { :regulation => @regulation }});
    end

    return collection
  end

  # Filter Systems by slug and/or the regulation of their attached controls.
  #
  # This is used for the respective filtering widgets.  The widgets store
  # their state in the session.
  def filter_systems(collection)
    control_search = {}
    unless session[:slugfilter].blank?
      control_search[:slug.like] = "#{session[:slugfilter]}%"
    end

    if session[:regulation_id]
      @regulation = Regulation.get(session[:regulation_id])
      control_search[:regulation] = @regulation
    end

    return collection if control_search.empty?
    return collection.all(:system_controls => {:control => control_search})
  end

  # Filter Biz Processes by slug and/or the regulation of their attached controls.
  #
  # This is used for the respective filtering widgets.  The widgets store
  # their state in the session.
  def filter_biz_processes(collection)
    co_search = {}
    unless session[:slugfilter].blank?
      co_search[:slug.like] = "#{session[:slugfilter]}%"
    end

    if session[:regulation_id]
      @regulation = Regulation.get(session[:regulation_id])
      co_search[:regulation] = @regulation
    end

    return collection if co_search.empty?
    return collection.all(:biz_process_control_objectives => { :control_objective => co_search})
  end

  # Shorthand humanized text for admin pages
  def pat(sym)
    sym.to_s.humanize
  end

  # Shorthand humanized text for admin pages
  def mt(sym)
    sym.to_s.humanize
  end

  # Shorthand humanized text for admin pages
  def mat(sym1, sym2)
    sym2.to_s.humanize
  end

  # Default time display (localize at some point)
  def display_time(time)
    time.strftime("%Y-%m-%d %H:%M") rescue "-"
  end

  # Display of regulation type
  def regulation_display(regulation)
    regulation.company? ? 'Company' : 'Regulation'
  end

  def render_for(tag, opts = {})
    content_for tag do
      render opts
    end
  end
end
