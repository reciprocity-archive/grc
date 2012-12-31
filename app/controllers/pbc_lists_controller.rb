# Handle PBC Lists

require 'csv'

class ImportException < Exception
end

class PbcListsController < BaseObjectsController
  include ImportHelper

  PBC_REQUEST_MAP = Hash[*%w(
    type_id type_name
    pbc_control_code pbc_control_code
    pbc_control_desc pbc_control_desc
    request request
    notes notes
    test test
    company_responsible company_responsible
    auditor_responsible auditor_responsible
    date_requested date_requested
    request_id request_id
    status status
    firm_responsible firm_responsible
  )]

  access_control :acl do
    # FIXME: Implement real authorization

    allow :superuser

    actions :index do
      allow :read, :read_pbc_list
    end

    actions :new, :create do
      allow :create, :create_pbc_list
    end

    actions :edit, :update do
      allow :update, :update_pbc_list, :of => :pbc_list
    end

    actions :show, :tooltip do
      allow :read, :read_pbc_list, :of => :pbc_list
    end

  end

  layout 'dashboard'

  def import
    @pbc_list = PbcList.find(params[:id])
    upload = params["upload"]
    if upload.present?
      begin
        file = upload.read.force_encoding('utf-8')
        import = { :messages => [], :pbc_list => @pbc_list }
        rows = CSV.parse(file)

        raise ImportException.new("There must be at least 2 input lines") unless rows.size >= 2

        read_import(import, PBC_REQUEST_MAP, "request", rows)

        @messages = import[:messages]
        do_import(import, params[:confirm].blank?)
        @warnings = import[:warnings]
        @errors = import[:errors]
        if params[:confirm].present? && !@errors.any? && !@messages.any?
          render :json => { :location => flow_pbc_list_path(@pbc_list) }
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

  def export
    @pbc_list = PbcList.find(params[:id])

    respond_to do |format|
      format.html do
        render :layout => 'export_modal', :locals => { :pbc_list => @pbc_list }
      end
      format.csv do
        self.response.headers['Content-Type'] = 'text/csv'
        headers['Content-Disposition'] = "attachment; filename=\"#{@pbc_list.display_name}.csv\""
        self.response_body = Enumerator.new do |out|
          out << CSV.generate_line(PBC_REQUEST_MAP.keys)
          @pbc_list.requests.each do |req|
            values = PBC_REQUEST_MAP.keys.map { |key| req.send(PBC_REQUEST_MAP[key]) if req.respond_to?(PBC_REQUEST_MAP[key]) }
            out << CSV.generate_line(values)
          end
        end
      end
    end
  end

  private

    def do_import(import, check_only)
      import[:errors] = {}
      import[:warnings] = {}

      @requests = []
      import[:requests].each_with_index do |attrs, i|
        import[:warnings][i] = HashWithIndifferentAccess.new

        attrs.delete(nil)
        attrs.delete('')
        attrs.delete('request_id')
        attrs.delete('status')
        attrs.delete('firm_responsible')
        attrs.delete('created_at')
        attrs.delete('updated_at')

        # determine what's internal type_id for given type_name
        # if not found use id from first request type
        type_name = attrs.delete('type_name')
        type_id = Request.types.rassoc(type_name).try(:first) || Request.types.first.first

        # try to find control with pbc_control_code
        pbc_control_code = attrs["pbc_control_code"]
        if pbc_control_code.present?
          control = Control.where(:slug => pbc_control_code).first

          if control
            # find or create ControlAssesment for given PbcList and Control
            control_assessment = ControlAssessment.where(
              :pbc_list_id => import[:pbc_list].id,
              :control_id => control.id).first
            control_assessment ||= ControlAssessment.new(
              :pbc_list => import[:pbc_list],
              :control => control)
          end
        end

        request = Request.new(:pbc_list => import[:pbc_list], :type_id => type_id)
        request.control_assessment = control_assessment if control_assessment.present?
        request.assign_attributes(attrs, :without_protection => true)
        request.date_requested = Time.zone.now.beginning_of_day if request.date_requested.blank?
        @requests << request

        import[:errors][i] = request.errors unless request.valid?

        request.save unless check_only
      end
    end

    def post_destroy_path
      flow_cycle_path(object.audit_cycle_id)
    end

    def pbc_list_params
      pbc_list_params = params[:pbc_list] || {}

      audit_cycle_id = pbc_list_params.delete(:audit_cycle_id)
      if audit_cycle_id.present?
        audit_cycle = Cycle.where(:id => audit_cycle_id).first
        if audit_cycle.present?
          pbc_list_params[:audit_cycle] = audit_cycle
        end
      end
      #%w(type).each do |field|
      #  parse_option_param(pbc_list_params, field)
      #end
      %w(list_import_date).each do |field|
        parse_date_param(pbc_list_params, field)
      end
      pbc_list_params
    end

    def delete_model_stats
      [
        [ 'Request', @pbc_list.requests.count ]
      ]
    end
end
