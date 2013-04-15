module SluggedModel
  def compact_slug
    return slug unless parent
    cslug = slug
    cslug[parent.slug] = '' if cslug[parent.slug] # Substring replacement of parent.slug with ''
    return cslug
  end

  def self.included(model)
    model.extend(ClassMethods)

    model.class_eval do
      validates :slug, :presence => { :message => "needs a value"}
      validates :slug,
        :uniqueness => { :message => "must be unique" }
      before_validation :generate_random_slug_if_needed
      after_validation :revert_generated_slug_if_needed
      before_save :generate_random_slug_if_needed
      before_validation :upcase_slug
      after_save :generate_human_slug_if_needed
      after_rollback :revert_generated_slug_if_needed
    end
  end

  def slug_split_for_sort
    self.slug.split(/(\d+)/).map { |s| [s.to_i, s] }
  end

  module ClassMethods
    def slugfilter(prefix)
      if !prefix.blank?
        where("#{table_name}.slug LIKE ?", "#{prefix}%").order(:slug)
      else
        order(:slug)
      end
    end

    def slugtree(items)
      st = SlugTree.new("")
      items.each { |item| st.insert(item) }
      st
    end

    def prepare_slug(slug)
      slug.strip.gsub(/\r|\n/, " ").upcase
    end
  end

  class SlugTree
    attr_accessor :prefix, :object, :parent, :children

    def initialize(prefix, parent=nil)
      @prefix = prefix
      @parent = parent

      @object = nil
      @children = {}
    end

    def insert(item)
      raise "Bad child slug: #{item.slug}" if !item.slug.starts_with?(@prefix)

      next_path = item.slug[@prefix.size..-1]
      next_step = next_path.split(/(?=\.|-|\(|\))/)[0]

      if next_step.blank?
        # Replace current node object
        @object = item
      else
        if !@children[next_step]
          @children[next_step] = SlugTree.new(@prefix + next_step, parent=self)
        end
        @children[next_step].insert(item)
      end
    end

    def first_level_descendents
      @children.map do |_, child|
        child.object.nil? ? child.first_level_descendents : child
      end.flatten
    end

    def first_level_descendents_with_step
      first_level_descendents.
        map { |node| [node.prefix[prefix.size..-1], node] }.
        sort_by { |k,_| k.split(/(\d+)/).map { |s| [s.to_i, s] } }
    end
  end

  def slug=(value)
    super(value.present? ? self.class.prepare_slug(value) : nil)
  end

  def default_slug_prefix
    self.class.to_s
  end

private

  def upcase_slug
    self.slug = slug.present? ? self.class.prepare_slug(slug) : nil
  end

  def generate_random_slug_if_needed
    @needs_slug = false
    if self.slug == nil
      if id.present? #!self.new_record?
        slug_suffix = '%04d' % id
      else
        @needs_slug = true
        slug_suffix = (Time.now.to_r*1000000).to_i.to_s(32) + '-' + Random.rand(1000000000).to_s(32)
      end

      new_slug = ''

      if self.has_attribute?(:parent_id) && !self.parent.nil?
        new_slug += self.parent.slug + '-'
      end
      new_slug += default_slug_prefix + '-' + slug_suffix
      self.slug = new_slug
    end
    true
  end

  def generate_human_slug_if_needed
    if @needs_slug
      self.without_versioning do
        new_slug = ''
        if self.has_attribute?(:parent_id) && !self.parent.nil?
          new_slug += self.parent.slug + '-'
        end
        self.slug = new_slug + default_slug_prefix + '-%04d' % id

        # HACK: Shouldn't recurse, but still a bit scary.
        try_count = 0
        while !self.save
          try_count += 1
          self.slug = new_slug + default_slug_prefix + ('-%04d' % id) + '-' + try_count.to_s
        end
      end
    end
    true
  end

  def revert_generated_slug_if_needed
    # In the case of a validation failure or some other save failure, revert the
    # slug back to nil if it was auto-generated.
    if @needs_slug
      self.slug = nil
    end
  end

  def validate_slug_parent
    upcase_slug
    return unless parent
    if slug && slug.starts_with?(parent.slug)
      true
    else
      errors.add(:slug, "must start with parent's code #{parent.slug}")
    end
  end
end
