class AddRequiredToOptions < ActiveRecord::Migration
  def change
    add_column :options, :required, :boolean
  end
end
