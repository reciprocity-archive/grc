class AddNotesToSystems < ActiveRecord::Migration
  def change
    add_column :systems, :notes, :text
  end
end
