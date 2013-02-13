class RemoveParentheticalsFromStatusValues < ActiveRecord::Migration
  REQUEST_STATUS_MIGRATIONS = [
    ["Responded (by Compliance)", "Responded"],
    ["Amended/Updated Request (by Auditor)", "Amended/Updated Request"],
    ["Accepted (by Auditor)", "Accepted"]
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
