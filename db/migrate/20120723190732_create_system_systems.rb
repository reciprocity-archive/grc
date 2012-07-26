class CreateSystemSystems < ActiveRecord::Migration
  def change
    create_table :system_systems do |t|
      t.references :parent, :null => false
      t.references :child, :null => false
      t.string :type
      t.integer :order
      t.references :modified_by
      t.timestamps
    end
  end
end
