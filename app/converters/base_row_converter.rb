
module ErrorWarningMessageObject
  attr_accessor :errors, :warnings, :messages

  def initialize
    @base_errors = []
    @errors = HashWithIndifferentAccess.new
    @base_warnings = []
    @warnings = HashWithIndifferentAccess.new
    @base_messages = []
    @messages = HashWithIndifferentAccess.new

    super
  end

  def add_error(key, message=nil)
    @errors[key] ||= []
    @errors[key].push(message)
  end

  def add_warning(key, message=nil)
    @warnings[key] ||= []
    @warnings[key].push(message)
  end
end

class BaseRowConverter
  include ErrorWarningMessageObject

  attr_accessor :importer, :attrs, :index, :options, :object, :handlers

  def initialize(importer, object_or_attrs, index, options=nil)
    @options = options || HashWithIndifferentAccess.new
    @importer = importer
    @index = index

    if @options[:export]
      @object = object_or_attrs
      @attrs = HashWithIndifferentAccess.new
    else
      @attrs = object_or_attrs || HashWithIndifferentAccess.new
      @object = nil
    end

    @handlers = HashWithIndifferentAccess.new

    @after_save_hooks = []

    super()
  end

  def errors_for(key)
    messages = []

    if @handlers.has_key?(key) && @handlers[key].errors.any?
      messages += @handlers[key].errors
    end

    messages += (errors[key] || []) + (object.valid? ? [] : object.errors[key])
    messages
  end

  def warnings_for(key)
    messages = []

    if @handlers.has_key?(key) && @handlers[key].warnings.any?
      messages += @handlers[key].warnings
    end
    if warnings.has_key?(key) && warnings[key].any?
      messages += warnings[key]
    end
    messages
  end

  def has_errors?
    !object.valid? || errors.any? || @handlers.values.any?(&:has_errors?)
  end

  def has_warnings?
    warnings.any? || @handlers.values.any?(&:has_warnings?)
  end

  def changed_attributes
    # Needs to change to handle LinkHandlers
    changed_attributes = object.changed_attributes.dup
    changed_attributes.each do |key, value|
      changed_attributes.delete(key) if object.send(key) == value
    end
    changed_attributes
  end

  def [](key)
    @handlers[key]
  end

  def setup
    if options[:export]
      setup_export
    else
      clean_attrs
      setup_object
    end
  end

  def clean_attrs
    attrs.keys.each do |key|
      attrs[key] = attrs[key].is_a?(String) ? attrs[key].strip : ''
    end
  end

  def setup_export
    attrs[:slug] = @object.slug
  end

  def setup_object
    setup_object_by_slug(attrs)
  end

  def setup_object_by_slug(attrs)
    slug = model_class.prepare_slug(attrs[:slug]) if attrs[:slug]
    if slug.blank?
      @object = model_class.new
    else
      @object = model_class.find_by_slug(slug)
      @object ||= @importer.find_object(model_class, { :slug => slug })
      @object ||= model_class.new(:slug => slug)
    end
    @importer.add_object(model_class, { :slug => slug }, @object)
    @object
  end

  def model_class
    return self.class.model_class
  end

  def self.model_class
    model_class = @model_class
    model_class = model_class.to_s if model_class.is_a?(Symbol)
    model_class = model_class.constantize if model_class.is_a?(String)
    model_class
  end

  def save
    object.save
    run_after_save_hooks(object)
  end

  def add_after_save_hook(hook=nil, &block)
    @after_save_hooks.push(hook) if hook
    @after_save_hooks.push(block) if block_given?
  end

  def run_after_save_hooks(object)
    @after_save_hooks.each do |hook|
      if hook.respond_to?(:after_save)
        hook.after_save(object)
      elsif hook.is_a?(Proc)
        hook.call(object)
      elsif hook.is_a?(Symbol) || hook.is_a?(String)
        self.send(hook, object)
      else
        raise
      end
    end
  end

  # Specify and run the handler for a given column
  def handle(key, handler_class, options=nil)
    @handlers[key] = handler_class.new(self, key, options || {})
    if self.options[:export]
      attrs[key] = @handlers[key].export
    else
      @handlers[key].import(attrs[key])
      add_after_save_hook(@handlers[key])
    end
  end

  # Short-hand for common/basic handlers
  def handle_text_or_html(key, options=nil)
    handle(key, TextOrHtmlColumnHandler, options)
  end

  def handle_option(key, options=nil)
    handle(key, OptionColumnHandler, options)
  end

  def handle_date(key, options=nil)
    handle(key, DateColumnHandler, options)
  end

  def handle_boolean(key, options=nil)
    handle(key, BooleanColumnHandler, options)
  end

  def handle_raw_attr(key, options=nil)
    handle(key, ColumnHandler, options)
  end

  # Set the attribute of the resulting object
  def set_attr(name, value)
    @object.send("#{name}=", value)
  end
end

class ColumnHandler
  attr_accessor :importer, :options, :errors, :warnings

  def initialize(importer, key, options)
    @importer = importer
    @key = key
    options ||= {}
    @options = options

    @original = nil
    @value = nil

    @errors = []
    @warnings = []
  end

  def add_error(message)
    @errors.push(message)
  end

  def add_warning(message)
    @warnings.push(message)
  end

  def has_errors?
    @errors.any? || (@importer.object.valid? ? nil : @importer.object.errors[@key])
  end

  def has_warnings?
    @warnings.any? || (@importer.warnings[@key] && @importer.warnings[@key].any?)
  end

  def display
    @importer.object.send(@key)
  end

  def after_save(object)
  end

  def parse_item(value)
    value
  end

  def validate(data)
  end

  def import(content)
    if content.present?
      @original = content
      data = parse_item(content)
      validate(data)
      if !data.nil?
        @value = data
        set_attr(data)
      end
    end
  end

  def set_attr(value)
    @importer.set_attr(@key, value)
  end

  def export
    if !options[:append_to]
      option = @importer.object.send("#{@key}")
    end
  end
end

class SlugColumnHandler < ColumnHandler
  # Don't overwrite slug on object
  def import(content)
    if content.present?
      @original = content
      @value = content
      validate(content)
    else
      add_warning("Code will be autofilled")
    end
  end
end


class TextOrHtmlColumnHandler < ColumnHandler
  def parse_item(value)
    if value.present?
      new_splits = (value ||"").
        split("\n---\n").
        map(&:strip)
      if options[:append_to]
        splits = (@importer.object.send(options[:append_to]) || "").
          split("\n---\n").
          map(&:strip)
        new_splits.each do |split|
          splits << split unless splits.include?(split)
        end
        new_splits = splits
      end
      #FIXME encoding issue on some inputs
      new_splits.
        map {|x| x.force_encoding('utf-8')}.
        join("\n---\n")
    end
  end

  def set_attr(value)
    key = options[:append_to] || @key
    @importer.set_attr(key, value)
  end
end

class OptionColumnHandler < ColumnHandler
  def parse_item(value)
    if value.present?
      role = options[:role] || @key
      option = Option.where(:role => role).all.find do |opt|
        opt.title.downcase == value.downcase
      end
      if option.nil?
        warnings.push("Unknown \"#{role}\" option \"#{value}\" -- create this option from the Admin Dashboard")
      end
      option
    end
  end
end

class BooleanColumnHandler < ColumnHandler
  def parse_item(value)
    if value.present?
      %w(yes 1 true).include?(value)
    end
  end
end

class DateColumnHandler < ColumnHandler
  def parse_item(value)
    if value.present?
      begin
        # If it's a US-looking date, convert to YYYY-MM-DD
        if value.respond_to?(:match) && value.match(/\d{1,2}\/\d{1,2}\/\d{4}/)
          value = Date.strptime(value, '%m/%d/%Y').to_s
        end

        # Parse via Rails
        value = Date.parse(value)
      rescue => e
        warnings.push("#{e}, use YYYY-MM-DD or MM/DD/YYYY format")
      end
      value
    end
  end

  def display
    has_errors? ? @original : @value
  end
end

# The base class for handling import of linked objects
class LinksHandler < ColumnHandler

  def initialize(importer, key, options)
    options ||= {}
    options[:association] = "#{key}" if !options.has_key?(:association)
    options[:append_only] = true     if !options.has_key?(:append_only)

    super(importer, key, options)

    @model_class = nil

    @preexisting_links = nil
    @link_status = {}
    @link_objects = {}

    @link_index = 0
    @link_values = {}
    @link_errors = {}
    @link_warnings = {}
  end

  def add_link_error(message)
    @link_errors[@link_index] ||= []
    @link_errors[@link_index].push(message)
  end

  def add_link_warning(message)
    @link_warnings[@link_index] ||= []
    @link_warnings[@link_index].push(message)
  end

  def add_created_link(object)
    @link_status[@link_index] = :created
    @link_objects[@link_index] = object
  end

  def add_existing_link(object)
    @link_status[@link_index] = :existing
    @link_objects[@link_index] = object
  end

  def has_errors?
    @errors.any? || @link_errors.values.any?(&:present?)
  end

  def has_warnings?
    @warnings.any? || @link_warnings.values.any?(&:present?)
  end

  def imported_links
    @link_objects.keys.select do |index|
      [:created, :existing].include?(@link_status[index])
    end.map do |index|
      @link_objects[index]
    end
  end

  def created_links
    @link_objects.keys.select do |index|
      @link_status[index] == :created
    end.map do |index|
      @link_objects[index]
    end
  end

  def display
    "XXX"
  end

  def display_link(object)
    object.title
  end

  def links_with_details
    @link_values.keys.map do |index|
      object = @link_objects[index]
      object_errors = object.nil? ? [] : object.errors.full_messages
      [ @link_status[index],
        @link_objects[index],
        @link_values[index],
        (@link_errors[index] || []) + object_errors,
        @link_warnings[index] || []
      ]
    end
  end

  def import(content)
    content = content || ""

    if @importer.options[:export] || @importer.object.new_record?
      @preexisting_links = []
    else
      @preexisting_links = get_existing_items
    end

    self.split_cell(content).each_with_index do |value, i|
      @link_index = i
      @link_values[@link_index] = value
      data = parse_item(value)
      next unless data

      linked_object = find_existing_item(data)

      if linked_object.nil?
        # New object
        linked_object = create_item(data)
        if !linked_object.nil?
          add_created_link(linked_object)
        end
      else
        # Existing object
        if @preexisting_links.include?(linked_object)
          # Existing relationship
          add_existing_link(linked_object)
        else
          # New relationship
          add_created_link(linked_object)
        end
      end
    end
  end

  def split_cell(value)
    value = value.
      split(/\n/).
      map(&:strip).
      compact.
      map { |item| item.starts_with?('[') ? item : item.split(',') }.
      flatten.
      map(&:strip).
      compact
  end

  def model_class
    model_class = options[:model_class].presence || self.class.model_class
    model_class = model_class.to_s if model_class.is_a?(Symbol)
    model_class = model_class.constantize if model_class.is_a?(String)
    model_class
  end

  def self.model_class
    model_class = @model_class
    model_class = model_class.to_s if model_class.is_a?(Symbol)
    model_class = model_class.constantize if model_class.is_a?(String)
    model_class
  end

  def get_where_params(data)
    { :slug => data[:slug] }
  end

  def get_create_params(data)
    data
  end

  def find_existing_item(data)
    where_params = get_where_params(data)
    model_class.where(where_params).first
  end

  def create_item(data)
    where_params = get_where_params(data)
    object = @importer.importer.find_object(model_class, where_params)
    if !object
      create_params = get_create_params(data)
      object = model_class.new(create_params)
      @importer.importer.add_object(model_class, where_params, object)
    end
    create_item_warnings(object, data)
    object
  end

  def create_item_warnings(object, data)
    add_link_warning("\"#{data[:slug]}\" will be created")
  end

  def get_existing_items
    @importer.object.send(options[:association])
  end

  def export
    join_rendered_items(get_existing_items.map { |item| render_item(item) })
  end

  def join_rendered_items(items)
    items.join("\n")
  end

  def render_item(item)
    return item.slug
  end

  def save_linked_objects
    success = true
    created_links.each do |link_object|
      success = link_object.save && success
    end
    success
  end

  def after_save(object)
    if options[:append_only]
      # Save old links plus new links
      if save_linked_objects
        object.send("#{options[:association]}=", @preexisting_links + created_links)
      else
        add_error("Failed to save necessary objects")
      end
    else
      # Overwrite with only imported links
      object.send("#{options[:association]}=", imported_links)
    end
  end
end

class LinkControlsHandler < LinksHandler
  @model_class = :Control

  def parse_item(data)
    { :slug => data.upcase }
  end

  def create_item(data)
    add_link_error("Control with code \"#{data[:slug]}\" doesn't exist")
    nil
  end
end

class LinkCategoriesHandler < LinksHandler
  @model_class = :Category

  def parse_item(data)
    { :name => data }
  end

  def get_where_params(data)
    { :name => data[:name], :scope_id => @options[:scope_id] }
  end

  def find_existing_item(data)
    items = model_class.where(:scope_id => @options[:scope_id]).all.select do |cat|
      cat.name.downcase == data[:name].downcase
    end
    if items.size > 1
      add_link_error("Multiple matches found for \"#{data[:name]}\" -- \"#{items.map(&:get_path).join("\", \"")\"")
    end
    items.first
  end

  def create_item(data)
    add_link_warning("Unknown category \"#{data[:name]}\" -- add this category from the Admin Dashboard")
    nil
  end

  def render_item(item)
    item.name
  end

  def display_link(object)
    object.name
  end
end

class LinkDocumentsHandler < LinksHandler
  @model_class = :Document

  def parse_item(value)
    if value.starts_with?('[')
      re = /^\[([^\s]+)(?:\s+([^\]]*))?\](.*)$/
      match = value.match(re)
      if match
        { :link => match[1], :title => match[2], :description => match[3] }
      else
        add_link_error("Invalid format")
        nil
      end
    else
      begin
        { :link => URI(value.strip).to_s }
      rescue URI::InvalidURIError => e
        add_link_error("Invalid format")
        nil
      end
    end
  end

  def get_where_params(data)
    link = Document.linkify(data[:link])
    { :link => link }
  end

  def create_item_warnings(object, data)
    add_link_warning("\"#{data[:title] || data[:link]}\" will be created")
  end

  def render_item(item)
    "[#{item.link_url} #{item.title}] #{item.description}"
  end
end

class LinkPeopleHandler < LinksHandler
  @model_class = Person

  def parse_item(value)
    if value.starts_with?('[')
      re = /^\[(\w+@[^\s\]]+)\s+(\w+)\]([\w\s]+)$/
      match = value.match(re)
      if match
        data = { :email => match[1], :name => match[3] }
      else
        add_link_error("Invalid format")
      end
    else
      data = { :email => value }
    end
    if data[:email].present? && !/^#{EmailValidator::EMAIL_RE}$/.match(data[:email])
      data[:email] = "#{data[:email]}@#{CMS_CONFIG['DEFAULT_DOMAIN']}"
    end
    data
  end

  def get_where_params(data)
    { :email => data[:email] }
  end

  #FIXME: Add an :allow_create option
  #def create_item(data)
  #  errors.push("No person with email \"#{data[:email]}\"")
  #  nil
  #end

  def get_create_params(data)
    { :email => data[:email], :name => data[:name] }
  end

  def create_item_warnings(object, data)
    add_link_warning("\"#{data[:email]}\" will be created")
  end

  def get_existing_items
    where_params = {}
    where_params[:role] = options[:role]
    where_params[:personable_type] = @importer.object.class.name
    where_params[:personable_id] = @importer.object.id
    object_people = ObjectPerson.where(where_params).includes(:person).all
    objects = object_people.map(&:person)
    objects
  end

  def after_save(object)
    created_links.each do |linked_object|
      linked_object.save
      object_person = ObjectPerson.new
      object_person.role = options[:role]
      object_person.personable = @importer.object
      object_person.person = linked_object
      object_person.save
    end
  end

  def render_item(item)
    item.email
  end

  def display_link(object)
    object.for_email
  end
end

class LinkSystemsHandler < LinksHandler
  @model_class = :System

  def parse_item(value)
    if value.starts_with?('[')
      re = /^(?:\[([\w\d-]+)\])([^$]+)$/
      match = value.match(re)
      if match
        { :slug => match[1], :title => match[2] }
      else
        add_link_error("Invalid format")
        nil
      end
    else
      { :slug => value.upcase, :title => value }
    end
  end

  def get_where_params(data)
    { :is_biz_process => false, :slug => data[:slug].strip.upcase }
  end

  def get_create_params(data)
    data.
      merge(
        :is_biz_process => false,
        :infrastructure => false,
        :slug => data[:slug].strip.upcase ).
      reverse_merge(
        :title => data[:slug])
  end

  def create_item(data)
    #type = options[:is_biz_process] ? "Process" : "System"
    add_link_error("System with code \"#{data[:slug]}\" doesn't exist")
    nil
  end
end

class LinkProcessesHandler < LinkSystemsHandler
  @model_class = :System

  def get_where_params(data)
    { :is_biz_process => true, :slug => data[:slug].strip.upcase }
  end

  def get_create_params(data)
    data.
      merge(
        :is_biz_process => true,
        :infrastructure => false,
        :slug => data[:slug].strip.upcase ).
      reverse_merge( :title => data[:slug] )
  end

  def create_item(data)
    add_link_error("Process with code \"#{data[:slug]}\" doesn't exist")
    nil
  end
end

class LinkRelationshipsHandler < LinksHandler
  def parse_item(value)
    if value.starts_with?('[')
      re = /^(?:\[([\w-]+)\])?([\w\s]+)$/
      match = value.match(re)
      if match
        { :slug => match[1].upcase, :title => match[2] }
      else
        add_link_error("Invalid format")
      end
    else
      { :slug => value.upcase }
    end
  end

  def get_existing_items
    where_params = {
      :relationship_type_id => options[:relationship_type_id]
    }

    if options[:direction] == :to
      where_params[:source_type] = @importer.object.class.name
      where_params[:source_id] = @importer.object.id
      where_params[:destination_type] = model_class.name
      relationships = Relationship.where(where_params).includes(:destination).all
      objects = relationships.map(&:destination)
    elsif options[:direction] == :from
      where_params[:destination_type] = @importer.object.class.name
      where_params[:destination_id] = @importer.object.id
      where_params[:source_type] = model_class.name
      relationships = Relationship.where(where_params).includes(:source).all
      objects = relationships.map(&:source)
    end

    objects
  end

  def after_save(object)
    created_links.each do |linked_object|
      linked_object.save
      relationship = Relationship.new(
        :relationship_type_id => options[:relationship_type_id])
      if options[:direction] == :to
        relationship.source = @importer.object
        relationship.destination = linked_object
      elsif options[:direction] == :from
        relationship.destination = @importer.object
        relationship.source = linked_object
      end
      relationship.save
    end
  end
end

