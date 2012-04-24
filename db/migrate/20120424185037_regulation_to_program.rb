class RegulationToProgram < ActiveRecord::Migration
  def up
    rename_table :regulations, :programs
    rename_table :control_objectives, :sections
    change_table :sections do |t|
      t.integer :parent_id
      t.index :parent_id
    end
  end
end
