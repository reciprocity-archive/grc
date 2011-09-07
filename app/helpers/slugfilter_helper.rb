module SlugfilterHelper
  def gen_slugs(prefix)
    slugs = ControlObjective.all.map { |co| co.slug }
    slugs = slugs.find_all { |s| s.start_with?(prefix) }
    slugs = slugs.sort

    slugs_with_depths = []
    stack = []
    has_more = {}

    slugs.each do |slug|
      stack = stack.find_all { |parent| slug.start_with?(parent) }
      slugs_with_depths << [slug, stack.length]
      stack.each { |parent| has_more[parent] = true }
      stack << slug
    end

    slugs_with_depths = slugs_with_depths.sort { |a, b| a[1] <=> b[1] }
    if slugs_with_depths.count { |swd| swd[1] == 0 } > 1
      slugs_with_depths = slugs_with_depths.find_all { |swd| swd[1] == 0 }
    else
      slugs_with_depths = slugs_with_depths.find_all { |swd| swd[1] == 1 }
    end

    slugs_with_depths.map do |swd|
      slug = swd[0]
      more_suffix = has_more[slug] ? '...' : ''
      { :label => "#{slug}#{more_suffix}", :value => "#{slug}" }
    end
  end
end
