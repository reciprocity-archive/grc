
class SystemRowConverter < BaseRowConverter
  @model_class = :System

  def setup_object
    object = setup_object_by_slug(attrs)
    if object.new_record?
      object.infrastructure = false if object.infrastructure.nil?
      object.is_biz_process = true if @importer.options[:is_biz_process]
    else
      if object.is_biz_process && !@importer.options[:is_biz_process]
        add_error(:slug, "Code is already used for a Process")
      elsif !object.is_biz_process && @importer.options[:is_biz_process]
        add_error(:slug, "Code is already used for a System")
      else
        type = @importer.options[:is_biz_process] ? 'Process' : 'System'
        add_warning(:slug, "#{type} already exists and will be updated")
      end
    end
  end

  def reify
    handle(:slug, SlugColumnHandler)

    handle(:controls, LinkControlsHandler)
    handle(:people_responsible, LinkPeopleHandler,
           :role => :responsible)
    handle(:people_accountable, LinkPeopleHandler,
           :role => :accountable)
    handle(:documents, LinkDocumentsHandler)

    handle(:sub_systems, LinkSystemsHandler,
           :is_biz_process => false)
    handle(:sub_processes, LinkSystemsHandler,
           :association => :sub_systems,
           :is_biz_process => true)

    handle_option(:network_zone)

    handle(:org_groups, LinkRelationshipsHandler,
           :model_class => OrgGroup,
           :relationship_type_id =>
            "org_group_is_responsible_for_#{ @importer.options[:is_biz_process] ? 'process' : 'system' }".to_sym,
           :direction => :from)

    handle_date(:start_date)
    handle_date(:created_at, :no_import => true)
    handle_date(:updated_at, :no_import => true)

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
    Link:People;Responsible people_responsible
    Link:People;Accountable people_accountable
    Link:Controls controls
    Append:Notes append_notes
    Link:System;Sub\ System sub_systems
    Link:Process;Sub\ Process sub_processes
    Link:Org\ Group;Overseen\ By org_groups
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
    if options[:is_biz_process]
      Hash[*self.class.object_map.map do |k,v|
        [k.sub("System Code", "Process Code"),v]
      end.flatten]
    else
      super
    end
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

