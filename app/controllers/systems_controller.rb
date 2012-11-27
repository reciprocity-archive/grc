# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

require 'csv'

class ImportException < Exception
end

# HandleSystems
class SystemsController < BaseObjectsController
  include ImportHelper

  SYSTEM_MAP = Hash[*%w(System\ Code slug Title title Description description Infrastructure infrastructure Owner owner Created created_at Updated updated_at)]

  access_control :acl do
    allow :superuser

    actions :new, :create, :import do
      allow :create, :create_system
    end

    allow :read, :read_system, :of => :system, :to => [:show,
                                                       :tooltip]

    actions :edit, :update do
      allow :update, :update_system, :of => :system
    end
  end

  layout 'dashboard'

  # TODO BASE OBJECTS
  # - use abstracted methods to handle 'index' cases

  def index
    @systems = System
    if params[:s].present?
      @systems = @systems.db_search(params[:s])
    end

    @systems = @systems.all

    if params[:as_subsystems_for].present?
      super_system_id = params[:as_subsystems_for].to_i
      if super_system_id.present?
        @systems = @systems.select { |s| s.id != super_system_id }
      end
    end

    render :json => @systems
  end

  def export
    respond_to do |format|
      format.csv do
        self.response.headers['Content-Type'] = 'text/csv'
        headers['Content-Disposition'] = "attachment; filename=\"SYSTEMS.csv\""
        self.response_body = Enumerator.new do |out|
          out << CSV.generate_line(SYSTEM_MAP.keys)
          System.all.each do |s|
            values = SYSTEM_MAP.keys.map { |key| s.send(SYSTEM_MAP[key]) }
            out << CSV.generate_line(values)
          end
        end
      end
    end
  end

  def import
    upload = params["upload"]
    if upload.present?
      begin
        file = upload.read.force_encoding('utf-8')
        import = read_import_systems(CSV.parse(file))
        @messages = import[:messages]
        do_import(import, params[:confirm].blank?)
        @warnings = import[:warnings]
        @errors = import[:errors]
        @creates = import[:creates]
        @updates = import[:updates]
        render 'import_result', :layout => false
      rescue CSV::MalformedCSVError, ArgumentError => e
        log_backtrace(e)
        render_import_error("Not a recognized file.")
      rescue ImportException => e
        render_import_error("Could not import file: #{e.to_s}")
      rescue => e
        log_backtrace(e)
        render_import_error
      end
    elsif request.post?
      render_import_error("Please select a file.")
    end
  end

  def do_import(import, check_only)
    import[:errors] = {}
    import[:updates] = []
    import[:creates] = []
    import[:warnings] = {}

    @systems = []
    import[:systems].each_with_index do |attrs, i|
      import[:warnings][i] = HashWithIndifferentAccess.new

      attrs.delete(nil)
      attrs.delete('created_at')
      attrs.delete('updated_at')
      if attrs['owner'].present?
        attrs['owner'] = Person.find_or_create_by_email!({:email => attrs['owner']})
      end

      slug = attrs['slug']

      if slug.blank?
        import[:warnings][i][:slug] ||= []
        import[:warnings][i][:slug] << "missing system slug"
        system = nil
      else
        system = System.find_by_slug(slug)
      end

      if system
        system.assign_attributes(attrs, :without_protection => true)
        import[:updates] << slug
      else
        system = System.new
        system.assign_attributes(attrs, :without_protection => true)
        import[:creates] << slug
      end
      @systems << system
      import[:errors][i] = system.errors unless system.valid?
      system.save unless check_only
    end
  end

  def read_import_systems(rows)
    import = { :messages => [] }

    raise ImportException.new("There must be at least 2 input lines") unless rows.size >= 2

    read_import(import, SYSTEM_MAP, "system", rows)

    import
  end

  private

    def delete_model_stats
      [ [ 'System Control', @system.system_controls.count ],
        [ 'System Section', @system.system_sections.count ]
      ]
    end

    def delete_relationship_stats
      [ [ 'Sub Systems', @system.sub_systems.count ],
        [ 'Super Systems', @system.super_systems.count ],
        [ 'Document', @system.documents.count ],
        [ 'Category', @system.categories.count ],
        [ 'Person', @system.people.count ]
      ]
    end

    def post_destroy_path
      programs_dash_path
    end

    def system_params
      system_params = params[:system] || {}
      %w(type).each do |field|
        value = system_params.delete(field + '_id')
        if value.present?
          system_params[field] = Option.find(value)
        end
      end

      # Fixup legacy boolean
      if system_params[:type]
        system_params[:infrastructure] = system_params[:type].title == 'Infrastructure'
      else
        system_params[:infrastructure] = false
      end

      system_params
    end
end
