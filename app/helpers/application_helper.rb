module ApplicationHelper
  ADMIN_MODULES = %w(accounts biz_processes business_areas cycles sections controls documents document_descriptors programs people systems)
  WORKFLOW_MODULES = %w(programs_dash controls dashboard evidence testing testreport) 

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
    [:superuser, :admin, :analyst, :guest]
  end

  # Filter SystemControl relationship objects by slug and/or program.
  #
  # This is used for the respective filtering widgets.  The widgets store
  # their state in the session.
  def filter_system_controls(collection)
    collection = collection.slugfilter(session[:slugfilter])
    if session[:program_id]
      @program = Program.find(session[:program_id])
      collection = collection.
        joins(:control).
        where({:control => { :program_id => @program.id }})
    end

    return collection
  end

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

  # Filter Biz Processes by slug and/or the program of their attached controls.
  #
  # This is used for the respective filtering widgets.  The widgets store
  # their state in the session.
  def filter_biz_processes(collection)
    co_search = {}
    unless session[:slugfilter].blank?
      co_search[:slug.like] = "#{session[:slugfilter]}%"
    end

    if session[:program_id]
      @program = Program.find(session[:program_id])
      co_search[:program_id] = @program
    end

    return collection.where({}) if co_search.empty?
    return collection.
      joins(:biz_process_sections => :section).
      where(:biz_process_sections => { :sections => co_search})
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

  # Display of program type
  def program_display(program)
    program.company? ? 'Company' : 'Program'
  end

  def render_for(tag, opts = {})
    content_for tag do
      render opts
    end
  end

  # Display a compact version of an object property
  def display_compact(model, object, prop)
    value = object.send(prop.name)
    if prop.name == :modified_by
      author = Account.find(value)
      link_to author.display_name, url_for(author)
    elsif prop.name.to_s.end_with?('_id')
      relation = prop.name.to_s.sub(/_id$/, '').to_sym
      other = model.relationships[relation].parent_model.find(value)
      if other
        link_to other.display_name, url_for(other)
      else
        "-"
      end
    elsif value.is_a? DateTime
      display_time(value)
    else
      value
    end
  end

  # Check if the set of ids coming from a form is already equal to the set of objects in an association.
  #
  # This is important for versioning so that we don't create a no-change versions.
  def equal_ids(ids, objects)
    return (ids.map {|x| x.to_i}).sort == (objects.map {|x| x.id}).sort
  end

  # Typecast form parameters into the right primitive to work around a DataMapper dirty-detection bug.
  #
  # If we don't do this, the persistence layer thinks all non-strings params are modifications
  # where in fact we might just have changed false => 0, which is a no-op.  This is important
  # for versioning so we don't create no-change versions when nothing was changed.
  def typecast_params(params, model)
    results = {}
    params.each do |key, value|
      property = model.properties[key.to_sym]
      if property && property.respond_to?(:typecast)
        value = property.typecast(value)
      end
      results[key] = value
    end
    results
  end

  # Use instead of 'yield :name' or 'content_for(:name)' in layouts for partials.
  # References:
  #   http://mikemayo.org/2012/rendering-a-collection-of-partials-with-content_for
  #   https://gist.github.com/rails/rails/pull/4226
  def yield_content!(name)
    view_flow.content.delete(name)
  end

  # Simple helper for repetitive form error spans
  def error_messages_inline(f, field_name)
    capture_haml do
      haml_tag :span, :class => 'help-inline' do
        f.object.errors[field_name].each do |error|
          haml_tag :span do
            haml_concat "#{error}"
          end
        end
      end
    end
  end

  def error_class(f, field_name)
    if !f.object.errors.empty?
      if f.object.errors[field_name].empty?
        'field-success'
      else
        'field-failure'
      end
    end
  end

  def member_error_messages_inline(o)
    capture_haml do
      if !o.errors.empty?
        haml_tag :span, :class => 'help-inline' do
          o.errors.each do |_, error|
            haml_tag :span do
              haml_concat "#{error}"
            end
          end
        end
      end
    end
  end

  def member_error_class(o)
    if o.changed?
      if !o.errors.empty?
        'member-failure'
      else
        'member-success'
      end
    end
  end
end
