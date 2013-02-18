class ControlSweeper < ActionController::Caching::Sweeper
  observe Control

  def after_create(control)
    expire_cache_for(control)
  end

  def after_update(control)
    expire_cache_for(control)
  end

  def after_destroy(control)
    expire_cache_for(control)
  end

  private
  def expire_cache_for(control)
    # only expire non-search fragments
    directive_id = control.directive.nil? ? control.directive_id : control.directive.id
    expire_fragment(:controller => 'mapping', :action => 'show',
                    :directive_id => directive_id,
                    :action_suffix => "company_controls_")
    expire_fragment(:controller => 'mapping', :action => 'show',
                    :directive_id => directive_id,
                    :action_suffix => "regulation_controls_")
  end
end
