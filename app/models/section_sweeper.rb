class SectionSweeper < ActionController::Caching::Sweeper
  observe Section, ControlSection

  # TODO: monitor implementing_controls

  def after_create(section)
    expire_cache_for(section)
  end

  def after_update(section)
    expire_cache_for(section)
  end

  def after_destroy(section)
    expire_cache_for(section)
  end

  private
  def expire_cache_for(section)
    if section.is_a?(ControlSection)
      section = section.section
    end

    # This can happen if deleting the section first.  The cache will expire, and the cached
    # values are inaccessible anyway.
    return if section.nil?

    directive_id = section.directive.nil? ? section.directive_id : section.directive.id
    # only expire non-search fragments
    expire_fragment(:controller => 'mapping', :action => 'show',
                    :directive_id => directive_id,
                    :action_suffix => "sections_")
  end
end
