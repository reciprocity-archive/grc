# Handle Risks

require 'csv'

class RisksController < BaseObjectsController
  include ImportHelper

  METADATA_MAP = Hash[*%w(Type type)]

  COLUMN_MAP = Hash[*%w(
    Code slug
    Title title
    Description description
    Likelihood\ Score likelihood_rating
    Likelihood\ Description likelihood
    Threat\ Vector threat_vector
    Trigger trigger
    Pre-Conditions preconditions
    Financial\ Impact\ Score financial_impact_rating
    Operational\ Impact\ Score operational_impact_rating
    Reputational\ Impact\ Score reputational_impact_rating
    Operational\ Impact\ Score operational_impact_rating
    Impact\ Description impact
    Inherent\ Risk\ Note inherent_risk
    Risk\ Mitigation\ Note risk_mitigation
    Residual\ Risk\ Note residual_risk
    URL url
    Link:Controls controls
    Link:Categories categories
  )]

  access_control :acl do
    # FIXME: Implement real authorization

    allow :superuser

    actions :index do
      allow :read, :read_risk
    end

    actions :new, :create do
      allow :create, :create_risk
    end

    actions :edit, :update do
      allow :update, :update_risk, :of => :risk
    end

    actions :show, :tooltip do
      allow :read, :read_risk, :of => :risk
    end

  end

  layout 'dashboard'

  def index
    @risks = Risk
    if params[:s].present?
      @risks = @risks.db_search(params[:s])
    end

    @risks = @risks.all

    respond_to do |format|
      format.html do
        if params[:quick]
          render :partial => 'quick', :locals => { :quick_result => params[:qr]}
        end
      end
      format.json do
        render :json => @risks
      end
    end
  end

  def import
    upload = params["upload"]
    if upload.present?
      begin
        file = upload.read.force_encoding('utf-8')
        #import = RisksImporter.new RiskRowImporter
        #import.import_csv(CSV.parse(file), params[:confirm].blank?)
        import = read_import_risks(CSV.parse(file))
        @messages = import[:messages]
        do_import(import, params[:confirm].blank?)
        @warnings = import[:warnings]
        @errors = import[:errors]
        @creates = import[:creates]
        @updates = import[:updates]
        if params[:confirm].present? && !@errors.any?
          flash[:notice] = "<i class='grcicon-ok'></i> #{@creates.size + @updates.size} Risks are Imported Successfully!".html_safe
          keep_flash_after_import
          render :json => { :location => programs_dash_path }
        else
          render 'import_result', :layout => false
        end
      rescue CSV::MalformedCSVError, ArgumentError => e
        log_backtrace(e)
        render_import_error("Not a recognized file.")
      rescue ImportHelper::ImportException => e
        render_import_error("Could not import file: #{e.to_s}")
      rescue => e
        log_backtrace(e)
        render_import_error
      end
    elsif request.post?
      render_import_error("Please select a file.")
    end
  end

  def read_import_risks(rows)
    import = { :messages => [] }

    raise ImportException.new("There must be at least 5 input lines") unless rows.size >= 5

    metadata_headers = read_import_headers(import, METADATA_MAP, :metadata, rows)

    metadata_values = rows.shift

    import[:metadata] = Hash[*metadata_headers.zip(metadata_values).flatten]

    validate_import_type(import[:metadata], "Risks")

    rows.shift
    rows.shift

    read_import(import, COLUMN_MAP, "risk", rows)

    import
  end

  def do_import(import, check_only)
    import[:errors] = {}
    import[:updates] = []
    import[:creates] = []
    import[:warnings] = {}

    @objects = []
    import[:risks].each_with_index do |attrs, i|
      import[:warnings][i] = HashWithIndifferentAccess.new

      attrs.delete(nil)
      attrs.delete('created_at')
      attrs.delete('updated_at')

      slug = attrs['slug']

      if slug.blank?
        import[:warnings][i][:slug] ||= []
        import[:warnings][i][:slug] << "missing object slug"
        object = nil
      else
        object = Risk.find_by_slug(slug)
      end

      object ||= Risk.new

      handle_import_category(object, attrs, 'categories', Control::CATEGORY_TYPE_ID)
      handle_import_controls(object, attrs, 'controls')
      #handle_import_systems(control, attrs, 'processes')

      object.assign_attributes(attrs, :without_protection => true)
      if object.new_record?
        import[:creates] << slug
      else
        import[:updates] << slug
      end
      @objects << object
      import[:errors][i] = object.errors unless object.valid?
      object.save unless check_only
    end
  end

  def export
    respond_to do |format|
      format.html do
        render :layout => 'export_modal', :locals => { }
      end
      format.csv do
        self.response.headers['Content-Type'] = 'text/csv'
        headers['Content-Disposition'] = "attachment; filename=\"RISKS.csv\""
        self.response_body = Enumerator.new do |out|
          out << CSV.generate_line(METADATA_MAP.keys)
          values = []
          values.unshift("Risks")
          out << CSV.generate_line(values)
          out << CSV.generate_line([])
          out << CSV.generate_line([])
          out << CSV.generate_line(COLUMN_MAP.keys)
          Risk.all.each do |s|
            values = COLUMN_MAP.keys.map do |key|
              field = COLUMN_MAP[key]
              case field
              when 'controls'
                (s.controls.map(&:slug).join(','))
              when 'categories'
                (s.categories.ctype(Control::CATEGORY_TYPE_ID).map {|x| x.name}).join(',')
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

  private

    def risk_params
      risk_params = params[:risk] || {}
      %w(start_date stop_date).each do |field|
        parse_date_param(risk_params, field)
      end
      risk_params
    end
end
