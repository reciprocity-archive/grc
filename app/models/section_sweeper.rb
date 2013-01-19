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

    program_id = section.program.nil? ? section.program_id : section.program.id
    # only expire non-search fragments
    expire_fragment(:controller => 'mapping', :action => 'show',
                    :program_id => program_id,
                    :action_suffix => "sections_")
  end
end
