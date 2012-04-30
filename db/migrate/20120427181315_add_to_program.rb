class AddToProgram < ActiveRecord::Migration
  def up
    change_table :programs do |t|
      t.integer :frequency_type, :default => 1
      t.integer :frequency, :default => 1
    end
  end

  def down
    change_table :programs do |t|
      t.remove :frequency, :frequency_type
    end
  end
end
