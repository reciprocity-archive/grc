class AddResponseDueAtToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :response_due_at, :date
  end
end
