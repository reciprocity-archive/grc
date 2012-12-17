class AddNotesToControls < ActiveRecord::Migration
  def change
    add_column :controls, :notes, :text
  end
end
