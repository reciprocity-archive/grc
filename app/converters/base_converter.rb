
require 'csv'

class ImportException < Exception
end

class BaseConverter

  attr_accessor :rows, :objects, :all_objects, :options, :warnings, :errors

  def initialize(rows_or_objects, options=nil)
    @options = options || {}

    if @options[:export]
      @objects = rows_or_objects
      @rows = []
    else
      @objects = []
      @rows = rows_or_objects.dup
    end

    @all_objects = {}

    @errors = []
    @warnings = []
  end

  # Import-only functionality
  def results
    @objects
  end

  def find_object(model_class, key)
    @all_objects[model_class][key] if @all_objects[model_class]
  end

  def add_object(model_class, key, object)
    @all_objects[model_class] ||= {}
    @all_objects[model_class][key] = object
  end

  def created_objects
    objects.select { |result| result.object.new_record? }
  end

  def updated_objects
    objects.reject { |result| result.object.new_record? }
  end

  def changed_objects
    objects.select { |result| result.changed_attributes.any? }
  end

  def has_errors?
    errors.any? || has_object_errors?
  end

  def has_object_errors?
    objects.any? { |result| result.has_errors? }
  end

  def has_warnings?
    warnings.any? || has_object_warnings?
  end

  def has_object_warnings?
    objects.any? { |result| result.has_warnings? }
  end

  def self.from_file(csv_file, options=nil)
    import_string(csv_file.read, options)
  end

  def self.from_string(csv_string, options=nil)
    self.from_rows(CSV.parse(csv_string.force_encoding('utf-8')), options)
  end

  def self.from_rows(rows, options=nil)
    self.new(rows, options)
  end

  def do_import(dry_run=true)
    import_metadata

    object_headers = read_headers(object_map, rows.shift)
    row_attrs = read_objects(object_headers, rows)
    row_attrs.each_with_index do |row_attrs, i|
      row = row_converter.new(self, row_attrs, i)
      row.setup
      row.reify
      objects.push(row)
    end

    if !dry_run
      save
    end
  end

  def import_metadata
    if rows.size < 5
      errors[:metadata].add("There must be at least 5 input lines")
      raise
      # Importer::AbortImport
    end

    headers = read_headers(metadata_map, rows.shift)
    values = read_values(headers, rows.shift)
    rows.shift
    rows.shift

    validate_metadata(values)
  end

  def validate_metadata(attrs)
  end

  def validate_metadata_type(attrs, type)
    if !attrs[:type].present?
      errors.push("Missing \"Type\" heading")
    elsif attrs[:type] != type
      errors.push("Type must be \"#{type}\"")
    end
  end

  def save
    ActiveRecord::Base.transaction do
      objects.each do |object|
        object.save
      end
      if has_errors?
        raise ActiveRecord::Rollback, "Errors encountered during save"
      end
    end
  end

  def register_callback(hook_key, method, args)
    @callbacks[hook_key] ||= []
    @callbacks[hook_key].push([method, args])
  end

  # Export-only functionality
  def do_export
    objects.each_with_index do |object, i|
      row = row_converter.new(self, object, i, :export => true)
      row.setup
      row.reify
      rows << row.attrs if row
    end

    row_header_map = object_map
    csv_rows = []
    rows.map do |row|
      csv_row = row_header_map.keys.map do |key|
        field = row_header_map[key]
        row[field.to_sym]
      end
      csv_rows << CSV.generate_line(csv_row)
    end
    csv_rows
  end

  # Common functionality
  def metadata_map
    self.class.metadata_map
  end

  def self.metadata_map
    @metadata_map
  end

  def object_map
    self.class.object_map
  end

  def self.object_map
    @object_map
  end

  def row_converter
    self.class.row_converter
  end

  def self.row_converter
    @row_converter
  end

  def get_header_for_column(column_name)
    object_map.each do |header, key|
      return header if key.to_sym == column_name.to_sym
    end
  end

  private

    def read_headers(import_map, row)
      # FIXME: Should also detect duplicate headers, or read_values should handle it
      ignored_columns = []

      keys = trim_array(row).map do |heading|
        heading = (heading || "").strip
        if heading.strip == "<skip>"
          next
        elsif !import_map.has_key?(heading)
          ignored_columns.push(heading)
          next
        else
          import_map[heading]
        end
      end

      if ignored_columns.any?
        ignored_text = ignored_columns.join(", ")
        warnings.push("Ignored column#{ 's' if ignored_columns.size > 1 }: #{ignored_text}")
      end

      missing_columns = import_map.values - keys
      if missing_columns.any?
        missing_text = missing_columns.map { |column| get_header_for_column(column) }.join(", ")
        warnings.push("Missing column#{ 's' if missing_columns.size > 1 }: #{missing_text}")
      end

      keys
    end

    def read_values(headers, row)
      attrs = HashWithIndifferentAccess.new
      headers.zip(row).each do |key, value|
        # FIXME: handle duplicate headers, or detect and warn in read_headers
        #if attrs.has_key?(key)
        #  attrs[key] = [attrs[key]] unless attrs[key].is_a?(Array)
        #  attrs[key].push(value)
        #else
          attrs[key] = value
        #end
      end
      attrs
    end

    def read_objects(headers, rows)
      rows.map do |row|
        next if !row.any?(&:present?)
        read_values(headers, row)
      end.compact
    end

    def trim_array(a)
      while !a.empty? && a.last.blank?
        a.pop
      end
      a
    end
end

