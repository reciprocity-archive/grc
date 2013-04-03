class AddReportDueAtToAuditCycle < ActiveRecord::Migration
  def change
    add_column :cycles, :report_due_at, :date
  end
end
