# Handle PBC Lists

require 'csv'

class ImportException < Exception
end

class PbcListsController < BaseObjectsController
  include ImportHelper

  PBC_METADATA_MAP = Hash[*%w(
    Type type
  )]

  PBC_REQUEST_MAP = Hash[*%w(
    Request\ Type type_name
    Control\ Code pbc_control_code
    Control\ Description pbc_control_desc
    Request request
    Notes notes
    Test test
    Internal\ Contact company_responsible
    Auditor\ Contact auditor_responsible
    Date\ Requested date_requested
    Request\ Id\ (auto-created) request_id
    status status
    firm_responsible firm_responsible
  )].merge("" => "")

#  access_control :acl do
#    # FIXME: Implement real authorization
#
#    allow :superuser
#
#    actions :index do
#      allow :read, :read_pbc_list
#    end
#
#    actions :new, :create do
#      allow :create, :create_pbc_list
#    end
#
#    actions :edit, :update do
#      allow :update, :update_pbc_list, :of => :pbc_list
#    end
#
#    actions :show, :tooltip do
#      allow :read, :read_pbc_list, :of => :pbc_list
#    end
#
#  end

  layout 'dashboard'

  def import
    @pbc_list = PbcList.find(params[:id])
    upload = params["upload"]
    if upload.present?
      begin
        file = upload.read.force_encoding('utf-8')
        import = read_import_requests(CSV.parse(file))
        @messages = import[:messages]
        do_import_requests(import, params[:confirm].blank?)
        @warnings = import[:warnings]
        @errors = import[:errors]
        if params[:confirm].present? && !@errors.any?
          flash[:notice] = "<i class='grcicon-ok'></i> Requests are imported successfully!".html_safe
          keep_flash_after_import
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
          out << CSV.generate_line(%w(Type))
          out << CSV.generate_line(["PBC Requests"])
          out << CSV.generate_line([])
          out << CSV.generate_line([])
          out << CSV.generate_line(PBC_REQUEST_MAP.keys)
          @pbc_list.requests.each do |req|
            values = PBC_REQUEST_MAP.keys.map { |key| req.send(PBC_REQUEST_MAP[key]) if req.respond_to?(PBC_REQUEST_MAP[key]) }
            out << CSV.generate_line(values)
          end
        end
      end
    end
  end

  def export_responses
    @pbc_list = PbcList.find(params[:id])

    respond_to do |format|
      format.html do
        render :layout => 'export_modal', :locals => { :pbc_list => @pbc_list }
      end
      format.csv do
        filename = "#{@pbc_list.display_name}-responses.csv"
        handle_csv_export(filename) do |out|
          headers = [
            "Response #",
            "Request Type",
            "Control Code",
            "PBC Control Description",
            "Request",
            "Request Status",
            "Internal Assignee",
            "Response Due Date",
            "Notes",
            "System/Process",
            "Drive Doclinks"
          ]
          out << CSV.generate_line(headers)

          requests = @pbc_list.requests.all
          by_ca_requests = sorted_requests_with_control_assessments(requests)
          by_ca_requests.each do |ca_id, ca, requests|
            control = ca && ca.control
            requests.each do |request|
              request.responses.each do |response|
                system_csv = ""
                system = response.system
                if system.present?
                  system_csv = system.slug
                  if system.title.present?
                    system_csv = "[#{system.slug}] #{system.title}"
                  end
                end

                data = [
                  response.id,
                  request.type_name,
                  control ? control.slug : request.pbc_control_code,
                  request.pbc_control_desc_stripped_with_newlines,
                  request.request_stripped_with_newlines,
                  request.status,
                  request.company_responsible,
                  request.response_due_at.present? ? request.response_due_at.strftime('%m/%d/%Y') : '',
                  request.notes,
                  system_csv,
                  response.csv_doclinks
                ]
                out << CSV.generate_line(data)
              end
            end
          end
        end
      end
    end
  end

  def new_object_path
  end

  private

    def do_import_requests(import, check_only)
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
        type_id = Request.types.rassoc(type_name).try(:first)

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

        if request.has_warnings?
          import[:warnings][i] = request.warnings
        end

        unless request.valid?
          if request.type_id.blank?
            request.errors.delete(:type_id)
            request.errors.add(:type_id, "invalid value, allowed values are: #{Request.types.values.to_sentence}")
          end

          import[:errors][i] = request.errors
        end

        request.save unless check_only
      end
    end

    def read_import_requests(rows)
      import = { :messages => [], :pbc_list => @pbc_list }

      raise ImportException.new("There must be at least 5 input lines") unless rows.size >= 5

      pbc_list_headers = read_import_headers(import, PBC_METADATA_MAP, "metadata", rows)
      pbc_list_values = rows.shift

      import[:metadata] = Hash[*pbc_list_headers.zip(pbc_list_values).flatten]

      validate_import_type(import[:metadata], "PBC Requests")

      rows.shift
      rows.shift

      read_import(import, PBC_REQUEST_MAP, "request", rows)

      import
    end

    def post_destroy_path
      flow_cycle_path(object.audit_cycle_id)
    end

    def delete_model_stats
      [
        [ 'Request', @pbc_list.requests.count ]
      ]
    end
end
