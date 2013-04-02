class MoveImportHelpPaths < ActiveRecord::Migration
  def up
    help = Help.where(:slug => 'import').first
    help.update_attribute(:slug, 'systems_import') if help
    help = Help.where(:slug => 'import_controls').first
    help.update_attribute(:slug, 'controls_import') if help
  end

  def down
  end
end
