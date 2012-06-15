class AddNaToSection < ActiveRecord::Migration
  def change
    add_column :sections, :na, :boolean, :null => false, :default => false
    add_column :sections, :notes, :text
  end
end
