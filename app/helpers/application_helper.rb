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
    %w(dashboard).map { |id| ProjectModule.new(id.humanize, url_for({:controller => id, :only_path => true})) }
  end

  def reset_session
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
end
