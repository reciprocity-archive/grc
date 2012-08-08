module ManyHelper
  # Edit one to many relationship.
  #
  # Example:
  #   edit_many(@control, :biz_process_controls, :biz_process) do |bpc|
  # 
  # will edit the BizProcesses attached to a control.
  def edit_many(obj, association, other, options = {})
    other_controller = options[:other_controller] || other.to_s.pluralize.to_sym
    return "" unless obj.id
    controller = obj.class.to_s.underscore.pluralize.to_sym
    destroy_method = "destroy_#{other}".to_sym
    obj.send(association).each do |assoc_item|
      item = assoc_item.send(other)
      haml_tag :tr do
        if item
          haml_tag :td do
            haml_tag :strong do
                haml_tag :a, :<, :href => url_for(:controller => other_controller, :action => :edit, :id => item.id) do
                  haml_concat item.display_name
                end
            end
          end
          yield(assoc_item)
          haml_tag :td do
            haml_concat link_to(pat(:detach), url_for(:controller => controller, :action => destroy_method, :id => obj.id, "#{other}_id" => item.id), :method => :delete, :class => :button)
          end
        else
          haml_tag :td do
            haml_concat "(deleted)"
            haml_concat link_to(pat(:detach),
                                url_for(:controller => controller, :action => destroy_method, :id => obj.id, "#{other}_id" => assoc_item.send("#{other}_id")),
                                :method => :delete, :class => :button)
          end
        end
      end

    end
  end

  # Edit one to many relationship - attach button.
  def edit_many_attach(obj, association, other)
    return "" unless obj.id
    controller = obj.class.to_s.underscore.pluralize.to_sym
    add_method = "add_#{other}".to_sym
    haml_concat link_to(pat(:attach), url_for(:controller => controller, :action => add_method, :id => obj.id), :class => :button)
  end

  # Edit one to many relationship without an explicit intermediary class.
  #
  # (Not currently used)
  def edit_many_anon(obj, other, other_controller=nil)
    other_controller ||= other
    other_controller = other_controller.to_s.pluralize.to_sym
    res = []
    return "" unless obj.id
    controller = obj.class.to_s.underscore.pluralize.to_sym
    destroy_method = "destroy_#{other}".to_sym
    add_method = "add_#{other}".to_sym
    haml_tag :table, :class => :table do
      haml_tag :tr do
        haml_tag :th, "Name"
        haml_tag :th
      end
      obj.send(other.to_s.pluralize).each do |item|
        haml_tag :tr do
          haml_tag :td, :class => :title do
            haml_tag :a, :<, :href => url(other_controller, :edit, item.id) do
              haml_concat item.display_name
            end
          end
          haml_tag :td do
            haml_concat link_to(pat(:detach), url(controller, destroy_method, obj.id, item.id), :method => :delete, :class => :button)
          end
        end
      end
    end
    haml_concat link_to(pat(:attach), url(controller, add_method, obj.id), :class => :button)
  end

  # Edit one to many relationship.
  #
  # Example:
  #
  #   edit_children(@program, :section)
  #
  # edits Control Objectives under a program.
  def edit_children(obj, other)
    res = []
    return "" unless obj.id
    controller = obj.class.to_s.underscore.pluralize.to_sym
    destroy_method = "destroy_#{other}".to_sym
    add_method = "add_#{other}".to_sym
    haml_tag :table, :class => :table do
      haml_tag :tr do
        haml_tag :th, "Name"
        haml_tag :th
      end
      obj.send(other.to_s.pluralize).each do |item|
        haml_tag :tr do
          haml_tag :td, :class => :title do
            haml_tag :a, :<, :href => url_for(:controller => other.to_s.pluralize.to_sym, :action => :edit, :id => item.id) do
              haml_concat item.display_name
            end
          end
        end
      end
    end
  end

  # Not currently used
  def edit_children_inline(obj, others, other_class=nil)
    if other_class.nil?
      other_class = others.to_s.singularize.to_sym
    end
    assoc = obj.send(others)
    assoc.each_with_index do |other_obj, index|
      #fields_for_indexed_subitem other_obj, others.to_s, index do |form|
      #  partial "#{other_class.to_s.pluralize}/indexed_subform", :locals => { :f => form, other_class => other_obj }
      #end
    end
    (0..1).each do |index|
      #fields_for_indexed_subitem other_class, others.to_s, index + assoc.size do |form|
      #  partial "#{other_class.to_s.pluralize}/indexed_subform", :locals => { :f => form, other_class => assoc.new }
      #end
    end
  end

  # Many to many AJAX page - show form.
  #
  # Example:
  #     if request.put?
  #       post_many2many(:left_class => Control,
  #                      :right_class => DocumentDescriptor,
  #                      :right_relation => :evidence_descriptors,
  #                      :right_ids => :evidence_descriptor_ids,
  #                      :lefts => filtered_controls)
  #     else
  #       get_many2many(:left_class => Control,
  #                     :lefts => filtered_controls,
  #                     :right_class => DocumentDescriptor,
  #                     :right_ids => :evidence_descriptor_ids,
  #                     :show_slugfilter => true)
  #     end

  def get_many2many(opts)
    left_class = opts[:left_class]
    left_class_underscore = left_class.to_s.underscore

    @right_class = opts[:right_class]
    right_class_underscore = @right_class.to_s.underscore

    @lefts = opts[:lefts] || left_class.order(:slug)

    @right_ids = opts[:right_ids] || (@right_class.to_s.underscore + "_ids").to_sym

    id = params[:id]
    if id.nil? || id == "0"
      if @lefts.empty?
        id = nil #left_class.first.id
      else
        id = @lefts.first.id
      end
    end

    if id
      @left = left_class.find(id)
      @rights = @right_class.send("for_#{left_class_underscore}".to_sym, @left) rescue @right_class
      @rights = @rights.order(:slug).all rescue @rights.all
      @show_slugfilter = opts[:show_slugfilter]
    end
  end

  # Many to many AJAX page - update.
  def post_many2many(opts)
    left_class = opts[:left_class]
    left_class_underscore = left_class.to_s.underscore

    right_class = opts[:right_class]
    right_class_underscore = right_class.to_s.underscore

    right_relation = opts[:right_relation] || right_class_underscore.pluralize

    right_ids = opts[:right_ids] || "#{right_class_underscore}_ids"

    left = left_class.find(params[:id])
    if params[left_class_underscore.to_sym]
      ids = params[left_class_underscore.to_sym][right_ids].map {|x| x.to_i}
    else
      ids = []
    end


    # left.rights = []
    if left.authored_update(current_user, {right_ids.to_sym => ids}, false)
      flash[:notice] = 'Successfully updated.'
    else
      flash[:error] = "Failed."
    end
    redirect_to :id => left.id
  end
end
