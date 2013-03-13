class RemoveDirectiveIdFromCycles < ActiveRecord::Migration
  def up
    remove_column :cycles, :directive_id
  end

  def down
    add_column :cycles, :directive_id, :integer
  end
end
