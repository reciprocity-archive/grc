class RemoveControlIdFromRequests < ActiveRecord::Migration
  def up
    # replace all controls with adequate control assessments
    Request.all.each do |request|
      if request.control_id.present?
        control_assessment = ControlAssessment.where(:control_id => request.control_id, :pbc_list_id => request.pbc_list_id).first

        if control_assessment.blank?
          begin
            control = Control.find(request.control_id)
            pbc_list = PbcList.find(request.pbc_list_id)
            control_assessment = ControlAssessment.create(:control => control, :pbc_list => pbc_list)
          rescue ActiveRecord::RecordNotFound
            # something is wrong with either control or pbc_list
            # leave request without control it will be displayed without it
            next
          end
        end

        request.control_assessment = control_assessment
        request.save
      end
    end

    remove_column :requests, :control_id
  end

  def down
    add_column :requests, :control_id, :integer
  end
end
