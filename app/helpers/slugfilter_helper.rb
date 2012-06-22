module SlugfilterHelper
  # Generate list of slugs to autocomplete in the slugfilter widget.
  def gen_slugs(prefix)
    slugs = Section.all.map { |co| co.slug }
    slugs = slugs.find_all { |s| s.start_with?(prefix) }
    organize_slugs(slugs)
  end

  def organize_slugs(slugs)
    # Get all slugs that start with the prefix
    slugs = slugs.sort

    slugs_with_depths = []
    stack = []
    has_more = {}

    # Iterate over each slug, and compute its "depth".
    # A slug is of depth n if there are n slugs that are a prefix of this slug.
    # 
    # Also compute the has_more map, which is true for any prefix where
    # there is a slug with that prefix.
    slugs.each do |slug|
      # Keep all prefixes of the current slug in the stack
      stack = stack.find_all { |parent| slug.start_with?(parent) }
      slugs_with_depths << [slug, stack.length]
      stack.each { |parent| has_more[parent] = true }
      stack << slug
    end

    # Sort by depth
    slugs_with_depths = slugs_with_depths.sort { |a, b| a[1] <=> b[1] }

    if slugs_with_depths.count { |swd| swd[1] == 0 } > 1
      # If there are multiple slugs with depth 0, show just those.
      # Depth 0 means that there is no other slug that is a prefix of this one.
      slugs_with_depths = slugs_with_depths.find_all { |swd| swd[1] == 0 }
    else
      # else show everything with depth 1
      slugs_with_depths = slugs_with_depths.find_all { |swd| swd[1] <= 1 }
    end

    slugs_with_depths.map do |swd|
      slug = swd[0]
      # Show an elipsis if this slug is a prefix of other slugs
      more_suffix = has_more[slug] ? '...' : ''
      { :label => "#{slug}#{more_suffix}", :value => "#{slug}" }
    end
  end

  def walk_slug_tree(tree, depth=nil, &block)
    capture_haml do
      walk_slug_tree_helper(tree, nil, true, depth, &block)
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
          haml_tag("ul", { :id => "children_#{tree.prefix}" }) do
            children.each do |step, child|
              walk_slug_tree_helper(child, step, odd, depth, &block)
            end
          end
        end
      end
    end
  end
end
