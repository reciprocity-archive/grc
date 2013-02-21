class AddKindToDirectives < ActiveRecord::Migration
  def change
    add_column :directives, :kind, :string
  end
end
