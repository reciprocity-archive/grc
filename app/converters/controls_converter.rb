
class ControlRowConverter < BaseRowConverter
  @model_class = :Control

  def setup_object
    object = setup_object_by_slug(attrs)
    if object.directive.present? && object.directive != @importer.options[:directive]
      add_warning(:slug, "Code is used in #{object.directive.slug}")
    else
      object.directive = @importer.options[:directive]
    end
  end

  def reify
    handle(:slug, SlugColumnHandler)

    handle_date(:start_date)
    handle_date(:stop_date)
    handle_date(:created_at)
    handle_date(:updated_at)

    handle_text_or_html(:description)
    handle_text_or_html(:documentation_description)

    handle_raw_attr(:title)
    handle_raw_attr(:url)

    handle_option(:kind, :role => :control_kind)
    handle_option(:means, :role => :control_means)
    handle_option(:verify_frequency)

    handle_boolean(:key_control)
    handle_boolean(:fraud_related)
    handle_boolean(:active)

    handle(:documents, LinkDocumentsHandler)
    handle(:people, LinkPeopleHandler,
           :role => :responsible)
    handle(:categories, LinkCategoriesHandler, :scope_id => Control::CATEGORY_TYPE_ID)
    handle(:assertions, LinkCategoriesHandler, :scope_id => Control::CATEGORY_ASSERTION_TYPE_ID)
    handle(:systems, LinkSystemsHandler)
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
    Link:Categories categories
    Link:Assertions assertions
    Documentation documentation_description
    Frequency verify_frequency
    References documents
    Link:People;Operator people
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

