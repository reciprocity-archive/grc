module SlugfilterHelper
  def walk_slug_tree(tree, depth=nil, &block)
    capture_haml do
      walk_slug_tree_children_helper(tree, nil, true, depth, &block)
    end
  end

  def walk_slug_tree_children_helper(tree, step=nil, odd=true, depth=nil, &block)
    children = tree.first_level_descendents_with_step

    children.each do |step, child|
      walk_slug_tree_helper(child, step, odd, depth, &block)
    end
  end

  def walk_slug_tree_helper(tree, step=nil, odd=true, depth=nil, &block)
    children = tree.first_level_descendents_with_step

    if tree.object && !depth.nil?
      depth = depth - 1
      children = [] if depth <= 0
    end

    if tree.object || !children.empty?
      haml_tag("li", { :id => "content_#{tree.prefix}" }) do
        if tree.object
          yield [tree.object, step]
        end
        if !children.empty?
          haml_tag("div.item-content.in") do
            haml_tag("ul.tree-structure", { :id => "children_#{tree.prefix}" }) do
              children.each do |step, child|
                walk_slug_tree_helper(child, step, odd, depth, &block)
              end
            end
          end
        end
      end
    end
  end
end
