class AddProgramIdToCycles < ActiveRecord::Migration
  def change
    add_column :cycles, :program_id, :integer
  end
end
