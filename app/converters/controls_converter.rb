
class ControlRowConverter < BaseRowConverter
  @model_class = :Control

  def setup_object
    object = setup_object_by_slug(attrs)
    if object.directive.present? && object.directive != @importer.options[:directive]
      add_error(:slug, "Code is used in #{object.directive.meta_kind.to_s.titleize}: #{object.directive.slug}")
    else
      object.directive = @importer.options[:directive]
    end
  end

  def reify
    handle(:slug, SlugColumnHandler)

    handle_date(:start_date)
    handle_date(:stop_date)
    handle_date(:created_at, :no_import => true)
    handle_date(:updated_at, :no_import => true)

    handle_text_or_html(:description)
    handle_text_or_html(:documentation_description)

    handle_raw_attr(:title)
    handle_raw_attr(:url)

    handle_option(:kind, :role => :control_kind)
    handle_option(:means, :role => :control_means)
    handle_option(:verify_frequency)

    handle_boolean(:key_control, :truthy_values => %w(key key_control key\ control))
    handle_boolean(:fraud_related, :truthy_values => %w(fraud fraud_related fraud\ related))
    handle_boolean(:active, :truthy_values => %w(active))

    handle(:documents, LinkDocumentsHandler)

    handle(:categories, LinkCategoriesHandler, :scope_id => Control::CATEGORY_TYPE_ID)
    handle(:assertions, LinkCategoriesHandler, :scope_id => Control::CATEGORY_ASSERTION_TYPE_ID)

    handle(:people_responsible, LinkPeopleHandler,
           :role => :responsible)
    handle(:people_accountable, LinkPeopleHandler,
           :role => :accountable)

    handle(:systems, LinkSystemsHandler,
           :is_biz_process => false)
    handle(:processes, LinkSystemsHandler,
           :association => :systems,
           :is_biz_process => true)
  end
end

class ControlsConverter < BaseConverter
  @metadata_map = Hash[*%w(
    Type type
    Directive\ Code slug
  )]

  @object_map = Hash[*%w(
    Control\ Code slug
    Title title
    Description description
    Kind kind
    Means means
    Version version
    Start\ Date start_date
    Stop\ Date stop_date
    URL url
    Link:Systems systems
    Link:Processes processes
    Link:Categories categories
    Link:Assertions assertions
    Documentation documentation_description
    Frequency verify_frequency
    References documents
    Link:People;Responsible people_responsible
    Link:People;Accountable people_accountable
    Key\ Control key_control
    Active active
    Fraud\ Related fraud_related
    Created created_at
    Updated updated_at
  )]

  @row_converter = ControlRowConverter

  def directive
    options[:directive]
  end

  def metadata_map
    Hash[*self.class.metadata_map.map do |k,v|
      [k.sub("Directive", directive.meta_kind.to_s.titleize),v]
    end.flatten]
  end

  def validate_metadata(attrs)
    validate_metadata_type(attrs, "Controls")

    if !attrs.has_key?(:slug)
      errors.push("Missing \"#{directive.meta_kind.to_s.titleize} Code\" heading")
    elsif attrs[:slug].upcase != directive.slug.upcase
      errors.push("#{directive.meta_kind.to_s.titleize} Code must be #{directive.slug}")
    end
  end

  def do_export_metadata
    yield CSV.generate_line(metadata_map.keys)
    yield CSV.generate_line(["Controls", directive.slug])
    yield CSV.generate_line([])
    yield CSV.generate_line([])
    yield CSV.generate_line(object_map.keys)
  end
end

