module SluggedModel
  module ClassMethods
    def slugfilter(prefix)
      if !prefix.blank?
        all(:slug.like => "#{prefix}%").all(:order => :slug)
      else
        all(:order => :slug)
      end
    end
  end

private
  def upcase_slug
    @slug = @slug.upcase
  end

  def validate_slug
    upcase_slug
    return unless parent
    if @slug.start_with?(parent.slug)
      true
    else
      [false, "control slug must start with parent's slug #{parent.slug}"]
    end
  end
end
