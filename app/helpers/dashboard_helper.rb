module DashboardHelper
  def init_quick_find
    @quick_find ||= {}
    @quick_find[:controls] ||= Control.all
    @quick_find[:systems] ||= System.all
    @quick_find[:biz_processes] ||= BizProcess.all
  end
end
