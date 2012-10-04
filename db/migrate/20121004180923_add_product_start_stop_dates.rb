class AddProductStartStopDates < ActiveRecord::Migration
  def up
    change_table :products do |t|
      t.datetime :start_date
      t.datetime :stop_date
    end
  end

  def down
    change_table :products do |t|
      t.remove :start_date
      t.remove :stop_date
    end
  end
end
