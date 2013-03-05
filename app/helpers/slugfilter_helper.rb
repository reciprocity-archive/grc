module SlugfilterHelper
  def walk_slug_tree(tree, options=nil, &block)
    options ||= {}
    depth = options[:depth]

    capture_haml do
      walk_slug_tree_children_helper(tree, nil, true, depth, options, &block)
    end
  end

  def walk_slug_tree_children_helper(tree, step=nil, odd=true, depth=nil, options=nil, &block)
    options ||= {}
    children = tree.first_level_descendents_with_step

    children.each do |step, child|
      walk_slug_tree_helper(child, step, odd, depth, options, &block)
    end
  end

  def walk_slug_tree_helper(tree, step=nil, odd=true, depth=nil, options=nil, &block)
    options ||= {}
    children = tree.first_level_descendents_with_step

    if tree.object && !depth.nil?
      depth = depth - 1
      children = [] if depth <= 0
    end

    if tree.object || !children.empty?
      haml_tag("li", { :id => "content_#{tree.prefix}", :class => options[:li_class] }) do
        if tree.object
          yield [tree.object, step, children]
        end
        if !children.empty?
          haml_tag("div.item-content", :class => options[:expanded] && 'in') do
            haml_tag("ul.tree-structure", { :id => "children_#{tree.prefix}" }) do
              children.each do |step, child|
                walk_slug_tree_helper(child, step, odd, depth, options, &block)
              end
            end
          end
        end
      end
    end
  end
end
