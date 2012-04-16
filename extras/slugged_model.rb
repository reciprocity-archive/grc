module SluggedModel
  def self.included(model)
    model.extend(ClassMethods)
  end

  module ClassMethods
    def slugfilter(prefix)
      if !prefix.blank?
        where("#{table_name}.slug LIKE ?", "#{prefix}%").order(:slug)
      else
        order(:slug)
      end
    end
  end

private
  def upcase_slug
    self.slug = slug.upcase
  end

  def validate_slug
    upcase_slug
    return unless parent
    if slug.start_with?(parent.slug)
      true
    else
      errors.add(:slug, "control slug must start with parent's slug #{parent.slug}")
    end
  end
end
