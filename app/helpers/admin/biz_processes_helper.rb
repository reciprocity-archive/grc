module Admin::BizProcessesHelper
  def update_biz_process_relations(bp, params)
    co_ids = params.delete("co_ids") || []

    bp.control_objectives = []
    co_ids.each do |co_id|
      co = ControlObjective.find(co_id)
      bp.control_objectives << co
    end

    control_ids = params.delete("control_ids") || []

    bp.controls = []
    control_ids.each do |control_id|
      control = Control.find(control_id)
      bp.controls << control
    end

    system_ids = params.delete("system_ids") || []

    bp.systems = []
    system_ids.each do |system_id|
      system = System.find(system_id)
      bp.systems << system
    end
  end
end
