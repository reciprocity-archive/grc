class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :scope_id
      t.integer :depth

      t.timestamps
    end

    create_table :categorizations do |t|
      t.references :category, :null => false
      t.references :stuff, :polymorphic => true, :null => false

      t.timestamps
    end
  end
end
