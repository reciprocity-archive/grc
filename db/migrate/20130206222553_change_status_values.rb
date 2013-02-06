class ChangeStatusValues < ActiveRecord::Migration

  # "Draft" remains "Draft" in the new arrangement.
  REQUEST_STATUS_MIGRATIONS = [
    ["Waiting Compliance", "Requested"],
    ["Waiting Auditors",   "Responded (by Compliance)"],
    ["Completed",          "Accepted (by Auditor)"]
  ]

  def up
    REQUEST_STATUS_MIGRATIONS.each do |oldstatus, newstatus|
      Request.where({:status => oldstatus}).each do |req|
        req[:status] = newstatus
        req.save
      end
    end
  end

  def down
  end
end
