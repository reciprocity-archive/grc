module ImportHelper
  def trim_array(a)
    while !a.empty? && a.last.blank?
      a.pop
    end
    a
  end

  def validate_import_slug(object, object_name, expected_slug)
    raise ImportException.new("#{object_name} Code column does not exist") unless object["slug"]
    raise ImportException.new("#{object_name} Code does not match current program") unless object["slug"] == expected_slug
  end

  def validate_import_type(object, expected_type)
    type = object.delete("type")
    raise ImportException.new("First column must be Type") unless type
    raise ImportException.new("Type must be #{expected_type}") unless type == expected_type
  end

  def read_import_headers(import, import_map, object_name, rows)
    trim_array(rows.shift).map do |heading|
      if heading == "Type"
        key = 'type'
      else
        key = import_map[heading]
        import[:messages] << "Invalid #{object_name} heading #{heading}" unless key
      end
      key
    end
  end

  def read_import(import, import_map, object_name, rows)
    headers = read_import_headers(import, import_map, object_name, rows)

    import[object_name.pluralize.to_sym] = rows.map do |values|
      Hash[*headers.zip(values).flatten]
    end
  end

  def render_import_error(message=nil)
    render '/error/import_error', :layout => false, :locals => { :message => message }
  end
end
