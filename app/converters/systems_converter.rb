
class SystemRowConverter < BaseRowConverter
  @model_class = :System

  def setup_object
    object = setup_object_by_slug(attrs)
    object.infrastructure = false if object.infrastructure.nil?
    object.is_biz_process = true if @importer.options[:is_biz_process]
  end

  def reify
    handle(:slug, SlugColumnHandler)
    handle(:people, LinkPeopleHandler,
           :role => :accountable)
    handle(:categories, LinkCategoriesHandler,
           :scope_id => System::CATEGORY_TYPE_ID)
    handle(:sub_systems, LinkSystemsHandler,
           :is_biz_process => false)
    handle(:sub_processes, LinkSystemsHandler,
           :association => :sub_systems,
           :is_biz_process => true)
    handle(:documents, LinkDocumentsHandler)
    handle_option(:network_zone)
    handle(:org_groups, LinkRelationshipsHandler,
           :model_class => OrgGroup,
           :relationship_type_id =>
            "org_group_is_responsible_for_#{ @importer.options[:is_biz_process] ? 'process' : 'system' }".to_sym,
           :direction => :from)

    handle_date(:start_date)
    handle_date(:created_at)
    handle_date(:updated_at)

    handle_text_or_html(:description)
    handle_text_or_html(:append_notes, :append_to => :description)

    handle_boolean(:infrastructure, :truthy_values => %w(infrastructure))

    handle_raw_attr(:title)
  end
end

class SystemsConverter < BaseConverter
  @metadata_map = Hash[*%w(
    Type type
  )]

  @object_map = Hash[*%w(
    System\ Code slug
    Title title
    Description description
    Link:References documents
    Infrastructure infrastructure
    Link:People;Owner people
    Link:Categories categories
    Link:Controls controls
    Append:Notes append_notes
    Link:System;Sub\ System sub_systems
    Link:Process;Sub\ Process sub_processes
    Link:Org\ Group org_groups
    Effective\ Date start_date
    Created created_at
    Updated updated_at
    Network\ Zone network_zone
  )]

  @row_converter = SystemRowConverter

  # Handle renaming of headers when options[:is_biz_process] is true
  def metadata_map
    Hash[*self.class.metadata_map.map do |k,v|
      [k.gsub("System", options[:is_biz_process] ? "Process" : "System"), v]
    end.flatten]
  end

  def object_map
    # Replace only the 'System Code' header, but not 'Link:System'
    object_map = self.class.object_map.dup
    if options[:is_biz_process]
      object_map.delete("System Code")
      object_map["Process Code"] = "slug"
    end
    object_map
  end

  def validate_metadata(attrs)
    type = options[:is_biz_process] ? "Processes" : "Systems"
    validate_metadata_type(attrs, type)
  end

  def do_export_metadata
    type = options[:is_biz_process] ? "Processes" : "Systems"
    yield CSV.generate_line(metadata_map.keys)
    yield CSV.generate_line([type])
    yield CSV.generate_line([])
    yield CSV.generate_line([])
    yield CSV.generate_line(object_map.keys)
  end
end

