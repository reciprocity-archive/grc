module DashboardHelper
  def init_quick_find
    @quick_find ||= {}
    @quick_find[:controls] ||= Control.all
    @quick_find[:systems] ||= System.where(:is_biz_process => false).all
    @quick_find[:biz_processes] ||= System.where(:is_biz_process => true).all
  end
end
