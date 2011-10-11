module ApplicationHelper
  class ProjectModule
    attr_accessor :name
    attr_accessor :path
    def initialize(name, path)
      @name = name
      @path = path
    end
  end

  def project_modules
    %w(dashboard evidence testing testreport).map { |id| ProjectModule.new(id.humanize, url_for({:controller => "/" + id, :only_path => true})) }
  end

  def admin_project_modules
    %w(accounts biz_processes business_areas control_objectives controls documents document_descriptors regulations people systems).map { |id| ProjectModule.new(id.humanize, url_for({:controller => "/admin/" + id, :only_path => true})) }
  end

  def access_control_roles
    [:admin, :analyst, :guest]
  end

  def reset_sessionx
    session[:user] = nil
    set_current_account(nil)
  end

  def filter_system_controls(collection)
    collection = collection.slugfilter(session[:slugfilter])
    if session[:regulation_id]
      @regulation = Regulation.get(session[:regulation_id])
      collection = collection.all({:control => { :regulation => @regulation }});
    end

    return collection
  end

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

  def pat(sym)
    sym.to_s.humanize
  end

  def mt(sym)
    sym.to_s.humanize
  end

  def mat(sym1, sym2)
    sym2.to_s.humanize
  end

  def display_time(time)
    time.strftime("%Y-%m-%d %H:%M") rescue "-"
  end

  def regulation_display(regulation)
    regulation.company? ? 'Company' : 'Regulation'
  end
end
