class AddTitleToHelps < ActiveRecord::Migration
  def change
    add_column :helps, :title, :string
  end
end
