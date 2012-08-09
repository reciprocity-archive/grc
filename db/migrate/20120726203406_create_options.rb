class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
      t.string :role, :null => false
      t.string :title, :null => false
      t.text :description

      t.references :modified_by
      t.timestamps
    end
  end
end
