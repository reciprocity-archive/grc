class AddMissingSystemFields < ActiveRecord::Migration
  def up
    change_table :systems do |t|
      t.datetime :start_date
      t.datetime :stop_date
      t.string :url
      t.string :version
    end
  end

  def down
    change_table :systems do |t|
      t.remove :start_date
      t.remove :stop_date
      t.remove :url
      t.remove :version
    end
  end
end
