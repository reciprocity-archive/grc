class AddEndAtToCycles < ActiveRecord::Migration
  def change
    add_column :cycles, :end_at, :date
  end
end
