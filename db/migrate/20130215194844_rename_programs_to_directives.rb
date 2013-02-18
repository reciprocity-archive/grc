class RenameProgramsToDirectives < ActiveRecord::Migration
  def up
    rename_table :programs, :directives

    rename_column :controls, :program_id, :directive_id
    rename_column :sections, :program_id, :directive_id
    rename_column :cycles, :program_id, :directive_id
  end

  def down
    rename_table :directives, :programs

    rename_column :controls, :directive_id, :program_id
    rename_column :sections, :directive_id, :program_id
    rename_column :cycles, :directive_id, :program_id
  end
end
