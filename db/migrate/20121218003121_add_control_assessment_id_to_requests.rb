class AddControlAssessmentIdToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :control_assessment_id, :integer
    add_index :requests, :control_assessment_id
  end
end
