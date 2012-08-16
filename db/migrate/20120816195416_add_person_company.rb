class AddPersonCompany < ActiveRecord::Migration
  def up
    add_column :people, :company, :string
  end

  def down
    remove_column :people, :company
  end
end
