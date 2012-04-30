module Admin::BizProcessesHelper
  def update_biz_process_relations(bp, params)
    sec_ids = params.delete("sec_ids") || []

    bp.sections = []
    sec_ids.each do |sec_id|
      sec = Section.find(sec_id)
      bp.sections << sec
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
