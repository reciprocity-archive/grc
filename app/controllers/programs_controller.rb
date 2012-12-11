# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

require 'csv'

class ImportException < Exception
end

# Browse programs
class ProgramsController < BaseObjectsController
  include ProgramsHelper
  include ImportHelper

  PROGRAM_MAP = Hash[*%w(Type type Program\ Code slug Program\ Title title Program\ Description description Company company Version version Start start_date Stop stop_date Kind kind Audit\ Start audit_start_date Audit\ Frequency audit_frequency Audit\ Duration audit_duration Created created_at Updated updated_at)]

  SECTION_MAP = Hash[*%w(Section\ Code slug Section\ Title title Section\ Description description Section\ Notes notes Created created_at Updated updated_at)]

  CONTROL_MAP = Hash[*%w(Control\ Code slug Title title Description description Type type Kind kind Means means Version version Start start_date Stop stop_date URL url Link:Systems systems Link:Categories categories Link:Assertions assertions Documentation documentation_description Verify-Frequency verify_frequency References references Link:People;Operator operator Key\ Control key_control Active active Fraud\ Related fraud_related Created created_at Updated updated_at)]

  # FIXME: Decide if the :section, controls, etc.
  # methods should be moved, and what access controls they
  # need.
  before_filter :load_program, :only => [:export_controls,
                                         :export,
                                         :import_controls,
                                         :import,
                                         :sections,
                                         :controls,
                                         :section_controls,
                                         :control_sections,
                                         :category_controls]

  cache_sweeper :section_sweeper, :only => [:destroy, :import]
  cache_sweeper :control_sweeper, :only => [:destroy, :import_controls]

  access_control :acl do
    allow :superuser

    allow :create, :create_program, :to => [:create,
                                   :new]
    allow :read, :read_program, :of => :program, :to => [:show,
                                                  :tooltip,
                                                  :sections,
                                                  :controls,
                                                  :section_controls,
                                                  :control_sections,
                                                  :category_controls]

    allow :update, :update_program, :of => :program, :to => [:edit,
                                                    :update,
                                                    :import_controls,
                                                    :export_controls,
                                                    :import,
                                                    :export]
  end

  layout 'dashboard'

  def index
    @programs = Program
    if params[:relevant_to]
      @programs = @programs.relevant_to(Product.find(params[:relevant_to]))
    end
    if params[:s]
      @programs = @programs.db_search(params[:s])
    end
    @programs = allowed_objs(@programs.all, :read)
  end

  def export_controls
    respond_to do |format|
      format.html do
        render :layout => 'export_modal', :locals => { :program => @program }
      end
      format.csv do
        self.response.headers['Content-Type'] = 'text/csv'
        headers['Content-Disposition'] = "attachment; filename=\"#{@program.slug}-controls.csv\""
        self.response_body = Enumerator.new do |out|
          out << CSV.generate_line(%w(Type Program\ Code))
          values = %w(Program\ Code).map { |key| @program.send(PROGRAM_MAP[key]) }
          values.unshift("Controls")
          out << CSV.generate_line(values)
          out << CSV.generate_line([])
          out << CSV.generate_line([])
          out << CSV.generate_line(CONTROL_MAP.keys)
          @program.controls.each do |s|
            values = CONTROL_MAP.keys.map do |key|
              field = CONTROL_MAP[key]
              case field
              when 'categories'
                (s.categories.ctype(Control::CATEGORY_TYPE_ID).map {|x| x.name}).join(',')
              when 'assertions'
                (s.categories.ctype(Control::CATEGORY_ASSERTION_TYPE_ID).map {|x| x.name}).join(',')
              when 'systems'
                (s.systems.map {|x| x.slug}).join(',')
              when 'operator'
                object_person = s.object_people.detect {|x| x.role == 'operator'}
                object_person ? object_person.person.email : ''
              when 'references'
                s.documents.map do |doc|
                  "#{doc.description} [#{doc.link} #{doc.title}]"
                end.join("\n")
              else
                s.send(field)
              end
            end
            out << CSV.generate_line(values)
          end
        end
      end
    end
  end

  def export
    respond_to do |format|
      format.html do
        render :layout => 'export_modal', :locals => { :program => @program }
      end
      format.csv do
        self.response.headers['Content-Type'] = 'text/csv'
        headers['Content-Disposition'] = "attachment; filename=\"#{@program.slug}.csv\""
        self.response_body = Enumerator.new do |out|
          out << CSV.generate_line(PROGRAM_MAP.keys)
          keys = PROGRAM_MAP.keys
          keys.shift
          values = keys.map { |key| @program.send(PROGRAM_MAP[key]) }
          values.unshift("Program")
          out << CSV.generate_line(values)
          out << CSV.generate_line([])
          out << CSV.generate_line([])
          out << CSV.generate_line(SECTION_MAP.keys)
          @program.sections.each do |s|
            values = SECTION_MAP.keys.map { |key| s.send(SECTION_MAP[key]) }
            out << CSV.generate_line(values)
          end
        end
      end
    end
  end

  def import_controls
    upload = params["upload"]
    if upload.present?
      begin
        file = upload.read.force_encoding('utf-8')
        import = read_import_controls(CSV.parse(file))
        @messages = import[:messages]
        do_import_controls(import, params[:confirm].blank?)
        @warnings = import[:warnings]
        @errors = import[:errors]
        @creates = import[:creates]
        @updates = import[:updates]
        if params[:confirm].present? && !@errors.any? && !@messages.any?
          render :json => { :location => flow_program_path(@program) }
        else
          render 'import_controls_result', :layout => false
        end
      rescue CSV::MalformedCSVError, ArgumentError => e
        log_backtrace(e)
        render_import_error("Not a recognized file.")
      rescue ImportException => e
        render_import_error("Could not import file: #{e.to_s}")
      rescue => e
        log_backtrace(e)
        render_import_error(e.class)
      end
    elsif request.post?
      render_import_error("Please select a file.")
    end
  end

  def import
    upload = params["upload"]
    if upload.present?
      begin
        file = upload.read.force_encoding('utf-8')
        import = read_import_sections(CSV.parse(file))
        @messages = import[:messages]
        do_import(import, params[:confirm].blank?)
        @warnings = import[:warnings]
        @errors = import[:errors]
        @creates = import[:creates]
        @updates = import[:updates]
        if params[:confirm].present? && !@errors.any? && !@messages.any?
          render :json => { :location => flow_program_path(@program) }
        else
          render 'import_result', :layout => false
        end
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

  def handle_option(attrs, name, messages, role = nil)
    role ||= name.to_sym
    if attrs[name]
      value = Option.where(:role => role, :title => attrs[name]).first
      if value.nil?
        messages << "Unknown #{role} option '#{attrs[name]}'"
      end
      attrs[name] = value
    end
  end

  def do_import_controls(import, check_only)
    import[:errors] = {}
    import[:updates] = []
    import[:creates] = []
    import[:warnings] = {}

    @controls = []
    import[:controls].each_with_index do |attrs, i|
      import[:warnings][i] = HashWithIndifferentAccess.new

      attrs.delete(nil)
      attrs.delete('created_at')
      attrs.delete('updated_at')
      attrs.delete('type')

      handle_option(attrs, 'kind', import[:messages], :control_kind)
      handle_option(attrs, 'means', import[:messages], :control_means)
      handle_option(attrs, 'verify_frequency', import[:messages])
      handle_boolean(attrs, 'key_control')
      handle_boolean(attrs, 'fraud_related')
      handle_boolean(attrs, 'active')
      handle_import_person(attrs, 'operator', import[:warnings][i])

      slug = attrs['slug']

      if slug.blank?
        import[:warnings][i][:slug] ||= []
        import[:warnings][i][:slug] << "missing control slug"
        control = nil
      else
        control = Control.find_by_slug(slug)
      end

      control ||= Control.new

      handle_import_document_reference(control, attrs, 'references', import[:warnings][i])
      handle_import_object_person(control, attrs, 'operator', 'operator')
      handle_import_category(control, attrs, 'categories', Control::CATEGORY_TYPE_ID)
      handle_import_category(control, attrs, 'assertions', Control::CATEGORY_ASSERTION_TYPE_ID)
      handle_import_systems(control, attrs, 'systems')

      control.assign_attributes(attrs, :without_protection => true)

      if control.new_record?
        control.program = @program
        import[:creates] << slug
      else
        import[:updates] << slug
      end
      @controls << control
      import[:errors][i] = control.errors unless control.valid?
      if control.program_id != @program.id
        import[:errors][i] ||= ActiveModel::Errors.new(control)
        import[:errors][i].add(:slug, "already used in another program")
      end
      control.save unless check_only
    end
  end

  def do_import(import, check_only)
    import[:errors] = {}
    import[:updates] = []
    import[:creates] = []
    import[:warnings] = {}

    @sections = []
    import[:sections].each_with_index do |attrs, i|
      import[:warnings][i] = HashWithIndifferentAccess.new

      attrs.delete(nil)
      attrs.delete('created_at')
      attrs.delete('updated_at')

      slug = attrs['slug']

      if slug.blank?
        import[:warnings][i][:slug] ||= []
        import[:warnings][i][:slug] << "missing section slug"
        section = nil
      else
        section = Section.find_by_slug(slug)
      end

      if section
        section.assign_attributes(attrs, :without_protection => true)
        import[:updates] << slug
      else
        section = Section.new
        section.assign_attributes(attrs, :without_protection => true)
        section.program = @program
        import[:creates] << slug
      end
      @sections << section
      import[:errors][i] = section.errors unless section.valid?
      if section.program_id != @program.id
        import[:errors][i] ||= ActiveModel::Errors.new(section)
        import[:errors][i].add(:slug, "already used in another program")
      end
      section.save unless check_only
    end
  end

  def read_import_controls(rows)
    import = { :messages => [] }

    raise ImportException.new("There must be at least 5 input lines") unless rows.size >= 5

    program_headers = read_import_headers(import, PROGRAM_MAP, "program", rows)

    program_values = rows.shift

    import[:program] = Hash[*program_headers.zip(program_values).flatten]

    validate_import_type(import[:program], "Controls")
    validate_import_slug(import[:program], "Program", @program.slug)

    rows.shift
    rows.shift

    read_import(import, CONTROL_MAP, "control", rows)

    import
  end

  def read_import_sections(rows)
    import = { :messages => [] }

    raise ImportException.new("There must be at least 5 input lines") unless rows.size >= 5

    program_headers = read_import_headers(import, PROGRAM_MAP, "program", rows)

    program_values = rows.shift

    import[:program] = Hash[*program_headers.zip(program_values).flatten]

    validate_import_type(import[:program], "Program")
    validate_import_slug(import[:program], "Program", @program.slug)

    rows.shift
    rows.shift

    read_import(import, SECTION_MAP, "section", rows)

    import
  end

  def sections
    @sections = @program.sections.includes(:controls => :implementing_controls)
    if params[:s]
      @sections = @sections.fulltext_search(params[:s])
    end
    @sections = allowed_objs(@sections.all.sort_by(&:slug_split_for_sort), :read)
    respond_to do |format|
      format.html do
        render :layout => nil, :locals => { :sections => @sections } 
      end
      format.json do 
        render :json => @sections, :methods => :linked_controls
      end
    end
  end

  def controls
    @controls = @program.controls.includes(:implementing_controls)
    if params[:s]
      @controls = @controls.fulltext_search(params[:s])
    end
    @controls = allowed_objs(@controls.all.sort_by(&:slug_split_for_sort), :read)
    respond_to do |format|
      format.html do
          render :layout => nil, :locals => { :controls => @controls }
      end
      format.json do 
        render :json => @controls, :methods => :implementing_controls
      end
    end
  end

  def section_controls
    if @program.company?
      @sections = @program.controls.includes(:implemented_controls => { :control_sections => :section }).map { |cc| cc.implemented_controls.map { |ic| ic.control_sections.map { |cs| cs.section } }.flatten }.flatten.uniq
    else
      @sections = @program.sections.includes(:controls => :implementing_controls).all
    end
    @sections.sort_by(&:slug_split_for_sort)
    @sections = allowed_objs(@sections, :read)
    render :layout => nil, :locals => { :sections => @sections }
  end

  def control_sections
    @controls = @program.controls.includes(:sections)
    if params[:s]
      @controls = @controls.fulltext_search(params[:s])
    end
    @controls = allowed_objs(@controls.all.sort_by(&:slug_split_for_sort), :read)
    render :layout => nil, :locals => { :controls => @controls }
  end

  def category_controls
    @category_tree = Category.roots.all.map do |category|
      branches = category.children.all.map do |subcategory|
        controls = subcategory.controls.where(:program_id => @program.id).all
        if !controls.empty?
          [subcategory, controls]
        end
      end.compact
      if !branches.empty?
        [category, branches]
      end
    end.compact

    uncategorized_controls = Control.
      includes(:categorizations).
      where(
        :program_id => @program.id,
        :categorizations => { :categorizable_id => nil }).
      all

    if !uncategorized_controls.empty?
      @category_tree.push([nil, uncategorized_controls])
    end

    render :layout => nil, :locals => { }
  end

  private

    def delete_model_stats
      [ [ 'Section', @program.sections.count ],
        [ 'Control', @program.controls.count ],
        [ 'Cycle', @program.cycles.count ]
      ]
    end

    def load_program
      @program = Program.find(params[:id])
    end

    def program_params
      program_params = params[:program] || {}
      if program_params[:type]
        program_params[:company] = (program_params.delete(:type) == 'company')
      end
      %w(start_date stop_date audit_start_date).each do |field|
        parse_date_param(program_params, field)
      end
      %w(kind audit_frequency audit_duration).each do |field|
        parse_option_param(program_params, field)
      end
      program_params
    end

end
