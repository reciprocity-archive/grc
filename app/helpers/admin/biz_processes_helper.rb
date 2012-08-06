module Admin::BizProcessesHelper
  def update_biz_process_relations(bp, params)
    sec_ids = params.delete("sec_ids") || []

    sections = []
    sec_ids.each do |sec_id|
      unless sec_id.blank?
        sec = Section.find(sec_id)
        sections << sec
      end
    end
    bp.sections = sections

    control_ids = params.delete("control_ids") || []

    controls = []
    control_ids.each do |control_id|
      unless control_id.blank?
        control = Control.find(control_id)
        controls << control
      end
    end
    bp.controls = controls

    system_ids = params.delete("system_ids") || []

    systems = []
    system_ids.each do |system_id|
      unless system_id.blank?
        system = System.find(system_id)
        systems << system
      end
    end
    bp.systems = systems
  end
end
