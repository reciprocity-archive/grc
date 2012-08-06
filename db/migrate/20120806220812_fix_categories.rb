class FixCategories < ActiveRecord::Migration
  def change
    change_table :categorizations do |t|
      t.belongs_to :modified_by
    end
    rename_column :categorizations, :stuff_id, :categorizable_id
    rename_column :categorizations, :stuff_type, :categorizable_type

    change_table :categories do |t|
      t.belongs_to :modified_by
    end
  end
end
