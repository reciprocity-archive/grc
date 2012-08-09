class AddSystemsIsBizProcess < ActiveRecord::Migration
  def up
    change_table :systems do |t|
      t.boolean :is_biz_process, :default => false
    end
  end

  def down
    change_table :systems do |t|
      t.remove :is_biz_process
    end
  end
end
