# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

require 'csv'

class ImportException < Exception
end

class DirectivesController < BaseObjectsController
  include DirectivesHelper
  include ImportHelper

  DIRECTIVE_MAP = Hash[*%w(Type type Directive\ Code slug Directive\ Title title Directive\ Description description Company company Version version Start start_date Stop stop_date Kind kind Audit\ Start audit_start_date Audit\ Frequency audit_frequency Audit\ Duration audit_duration Created created_at Updated updated_at)]

  SECTION_MAP = Hash[*%w(Section\ Code slug Section\ Title title Section\ Description description Section\ Notes notes Created created_at Updated updated_at)]

  CONTROL_MAP = Hash[*%w(Control\ Code slug Title title Description description Kind kind Means means Version version Start start_date Stop stop_date URL url Link:Systems systems Link:Categories categories Link:Assertions assertions Documentation documentation_description Frequency verify_frequency References references Link:People;Operator operator Key\ Control key_control Active active Fraud\ Related fraud_related Created created_at Updated updated_at)]

  # FIXME: Decide if the :section, controls, etc.
  # methods should be moved, and what access controls they
  # need.
  before_filter :load_directive, :only => [:export_controls,
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

    allow :create, :create_directive, :to => [:create,
                                   :new]
    allow :read, :read_directive, :of => :directive, :to => [:show,
                                                  :tooltip,
                                                  :sections,
                                                  :controls,
                                                  :section_controls,
                                                  :control_sections,
                                                  :category_controls]

    allow :update, :update_directive, :of => :directive, :to => [:edit,
                                                    :update,
                                                    :import_controls,
                                                    :export_controls,
                                                    :import,
                                                    :export]
  end

  layout 'dashboard'

  def index
    @directives = Directive
    if params[:relevant_to].present?
      @directives = @directives.relevant_to(Product.find(params[:relevant_to]))
    end
    if params[:s].present?
      @directives = @directives.db_search(params[:s])
    end
    if params[:program_id].present?
      @directives = @directives.joins(:program_directives).where(:program_directives => { :program_id => params[:program_id] })
    end
    @directives = allowed_objs(@directives.all, :read)

    respond_to do |format|
      format.html do
        if params[:quick].present?
          render :partial => 'quick', :locals => { :quick_result => params[:qr]}
        end
        if params[:tree].present?
          render :partial => 'tree', :locals => { :directives => @directives }
        end
      end
      format.json do
        render :json => @directives
      end
    end
  end

  def export_controls
    respond_to do |format|
      format.html do
        render :layout => 'export_modal', :locals => { :directive => @directive }
      end
      format.csv do
        self.response.headers['Content-Type'] = 'text/csv'
        headers['Content-Disposition'] = "attachment; filename=\"#{@directive.slug}-controls.csv\""
        self.response_body = Enumerator.new do |out|
          out << CSV.generate_line(%w(Type Directive\ Code))
          values = %w(Directive\ Code).map { |key| @directive.send(DIRECTIVE_MAP[key]) }
          values.unshift("Controls")
          out << CSV.generate_line(values)
          out << CSV.generate_line([])
          out << CSV.generate_line([])
          out << CSV.generate_line(CONTROL_MAP.keys)
          @directive.controls.each do |s|
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
        render :layout => 'export_modal', :locals => { :directive => @directive }
      end
      format.csv do
        self.response.headers['Content-Type'] = 'text/csv'
        headers['Content-Disposition'] = "attachment; filename=\"#{@directive.slug}.csv\""
        self.response_body = Enumerator.new do |out|
          out << CSV.generate_line(DIRECTIVE_MAP.keys)
          keys = DIRECTIVE_MAP.keys
          keys.shift
          values = keys.map { |key| @directive.send(DIRECTIVE_MAP[key]) }
          values.unshift("Directive")
          out << CSV.generate_line(values)
          out << CSV.generate_line([])
          out << CSV.generate_line([])
          out << CSV.generate_line(SECTION_MAP.keys)
          @directive.sections.each do |s|
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
          render :json => { :location => flow_directive_path(@directive) }
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
          render :json => { :location => flow_directive_path(@directive) }
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

      handle_option(attrs, 'kind', import[:warnings][i], :control_kind)
      handle_option(attrs, 'means', import[:warnings][i], :control_means)
      handle_option(attrs, 'verify_frequency', import[:warnings][i])
      handle_boolean(attrs, 'key_control')
      handle_boolean(attrs, 'fraud_related')
      handle_boolean(attrs, 'active')
      handle_import_person(attrs, 'operator', import[:warnings][i], :warning_message => "Warning: unrecognized value. This field should be an LDAP id or an email. Data will be ignored if import proceeds.")

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

      attrs['title'] ||= attrs['description'].split("\n")[0] rescue ""

      control.assign_attributes(attrs, :without_protection => true)

      if control.new_record?
        control.directive = @directive
        import[:creates] << slug
      else
        import[:updates] << slug
      end
      @controls << control
      import[:errors][i] = control.errors unless control.valid?
      if control.directive_id != @directive.id
        import[:errors][i] ||= ActiveModel::Errors.new(control)
        import[:errors][i].add(:slug, "already used in another directive")
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
        section.directive = @directive
        import[:creates] << slug
      end
      @sections << section
      import[:errors][i] = section.errors unless section.valid?
      if section.directive_id != @directive.id
        import[:errors][i] ||= ActiveModel::Errors.new(section)
        import[:errors][i].add(:slug, "already used in another directive")
      end
      section.save unless check_only
    end
  end

  def read_import_controls(rows)
    import = { :messages => [] }

    raise ImportException.new("There must be at least 5 input lines") unless rows.size >= 5

    directive_headers = read_import_headers(import, DIRECTIVE_MAP, "directive", rows)

    directive_values = rows.shift

    import[:directive] = Hash[*directive_headers.zip(directive_values).flatten]

    validate_import_type(import[:directive], "Controls")
    validate_import_slug(import[:directive], "Directive", @directive.slug)

    rows.shift
    rows.shift

    read_import(import, CONTROL_MAP, "control", rows)

    import
  end

  def read_import_sections(rows)
    import = { :messages => [] }

    raise ImportException.new("There must be at least 5 input lines") unless rows.size >= 5

    directive_headers = read_import_headers(import, DIRECTIVE_MAP, "directive", rows)

    directive_values = rows.shift

    import[:directive] = Hash[*directive_headers.zip(directive_values).flatten]

    validate_import_type(import[:directive], "Directive")
    validate_import_slug(import[:directive], "Directive", @directive.slug)

    rows.shift
    rows.shift

    read_import(import, SECTION_MAP, "section", rows)

    import
  end

  def sections
    @sections = @directive.sections.includes(:controls => :implementing_controls)
    if params[:s]
      @sections = @sections.fulltext_search(params[:s])
    end
    @sections = allowed_objs(@sections.all.sort_by(&:slug_split_for_sort), :read)
    respond_to do |format|
      format.html do
        render :layout => nil, :locals => { :sections => @sections } 
      end
      format.json do 
        render :json => @sections, :methods => [:linked_controls, :description_inline]
      end
    end
  end

  def controls
    @controls = @directive.controls.includes(:implementing_controls)
    if params[:s]
      @controls = @controls.fulltext_search(params[:s])
    end
    @controls = allowed_objs(@controls.all.sort_by(&:slug_split_for_sort), :read)
    respond_to do |format|
      format.html do
          render :layout => nil, :locals => { :controls => @controls }
      end
      format.json do 
        render :json => @controls, :methods => [:implementing_controls, :description_inline]
      end
    end
  end

  def section_controls
    if @directive.company?
      @sections = @directive.controls.includes(:implemented_controls => { :control_sections => :section }).map { |cc| cc.implemented_controls.map { |ic| ic.control_sections.map { |cs| cs.section } }.flatten }.flatten.uniq
    else
      @sections = @directive.sections.includes(:controls => :implementing_controls).all
    end
    @sections.sort_by(&:slug_split_for_sort)
    @sections = allowed_objs(@sections, :read)
    render :layout => nil, :locals => { :sections => @sections }
  end

  def control_sections
    @controls = @directive.controls.includes(:sections)
    if params[:s]
      @controls = @controls.fulltext_search(params[:s])
    end
    @controls = allowed_objs(@controls.all.sort_by(&:slug_split_for_sort), :read)
    respond_to do |format|
      format.html do
        render :layout => nil, :locals => { :controls => @controls }
      end
      format.json do
        render :json => @controls.map {|o| o.id}
      end
    end
  end

  def category_controls
    categories = Category.ctype(Control::CATEGORY_TYPE_ID).roots.all
    @category_tree = categories.map do |category|
      category_controls_tree(@directive, category)
    end.compact

    uncategorized_controls = Control.
      includes(:categorizations).
      where(
        :directive_id => @directive.id,
        :categorizations => { :categorizable_id => nil }).
      all

    if !uncategorized_controls.empty?
      @category_tree.push([nil, nil, uncategorized_controls])
    end

    render :layout => nil
  end

  def new_object_title
    "Directive or Policy"
  end

  private

    # Construct the category controls tree
    #   - if neither the current category nor descendants contains controls
    #     then return nil
    #   - else return [category, category_controls_tree(category), controls]
    def category_controls_tree(directive, category)
      controls = category.controls.where(:directive_id => directive).all
      children = category.children.all.map do |subcategory|
        category_controls_tree(directive, subcategory)
      end.compact
      if controls.size > 0 || children.size > 0
        [category, children, controls]
      else
        nil
      end
    end

    def delete_model_stats
      [ [ 'Section', @directive.sections.count ],
        [ 'Control', @directive.controls.count ],
        [ 'Cycle', @directive.cycles.count ]
      ]
    end

    def load_directive
      @directive = Directive.find(params[:id])
    end

    def directive_params
      directive_params = params[:directive] || {}
      if directive_params[:type]
        directive_params[:company] = (directive_params.delete(:type) == 'company')
      end
      %w(start_date stop_date audit_start_date).each do |field|
        parse_date_param(directive_params, field)
      end
      %w(kind audit_frequency audit_duration).each do |field|
        parse_option_param(directive_params, field)
      end
      directive_params
    end

end
