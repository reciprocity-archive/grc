module ManyHelper
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
