
class SectionRowConverter < BaseRowConverter
  @model_class = :Section
  @@slugs = []
  
  def setup_object
    object = setup_object_by_slug(attrs)
    if object.directive.present? && object.directive != @importer.options[:directive]
      add_error(:slug, "Code is used in #{object.directive.meta_kind.to_s.titleize}: #{object.directive.slug}")
    else
      object.directive = @importer.options[:directive]
      if @@slugs.include? object.directive.slug
        add_error(:slug, "Code is duplicated")
      else
        @@slugs << object.directive.slug
      end
    end
  end

  def reify
    handle(:slug, SlugColumnHandler)

    handle_date(:created_at, :no_import => true)
    handle_date(:updated_at, :no_import => true)

    handle_text_or_html(:description)
    handle_text_or_html(:notes)

    handle(:controls, LinkControlsHandler)

    handle_raw_attr(:title)
  end

end

class SectionsConverter < BaseConverter
  @metadata_map = Hash[*%w(
    Type type
    Directive\ Code slug
    Directive\ Title title
    Directive\ Description description
    Version version
    Start start_date
    Stop stop_date
    Kind kind
    Audit\ Start audit_start_date
    Audit\ Frequency audit_frequency
    Audit\ Duration audit_duration
    Created created_at
    Updated updated_at
  )]

  @object_map = Hash[*%w(
    Section\ Code slug
    Section\ Title title
    Section\ Description description
    Abstract notes
    Controls controls
    Created created_at
    Updated updated_at
  )]

  @row_converter = SectionRowConverter

  def directive
    options[:directive]
  end

  def metadata_map
    # Change 'Directive' to 'Contract', 'Policy', or 'Regulation'
    Hash[*self.class.metadata_map.map do |k,v|
      [k.sub("Directive", directive.meta_kind.to_s.titleize),v]
    end.flatten]
  end

  def object_map
    # Change 'Section' to 'Clause' in some cases
    Hash[*self.class.object_map.map do |k,v|
      [k.sub("Section", directive.section_meta_kind.to_s.titleize),v]
    end.flatten]
  end

  def validate_metadata(attrs)
    validate_metadata_type(attrs, directive.meta_kind.to_s.titleize)

    if !attrs.has_key?(:slug)
      errors.push("Missing \"#{directive.meta_kind.to_s.titleize} Code\" heading")
    elsif attrs[:slug].upcase != directive.slug.upcase
      errors.push("#{directive.meta_kind.to_s.titleize} Code must be #{directive.slug}")
    end
  end

  def do_export_metadata
    yield CSV.generate_line(metadata_map.keys)
    yield CSV.generate_line([directive.meta_kind.to_s.titleize, directive.slug])
    yield CSV.generate_line([])
    yield CSV.generate_line([])
    yield CSV.generate_line(object_map.keys)
  end
end

