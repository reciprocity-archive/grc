class AddRequiredToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :required, :boolean
  end
end
