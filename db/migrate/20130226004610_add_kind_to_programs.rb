class AddKindToPrograms < ActiveRecord::Migration
  def change
    add_column :programs, :kind, :string
  end
end
