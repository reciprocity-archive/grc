class UniqueSlug < ActiveRecord::Migration
  def up
    add_index :sections, :slug, :unique => true
    add_index :controls, :slug, :unique => true
    add_index :biz_processes, :slug, :unique => true
    add_index :systems, :slug, :unique => true
    add_index :programs, :slug, :unique => true
  end

  def down
    remove_index :sections, :slug
    remove_index :controls, :slug
    remove_index :biz_processes, :slug
    remove_index :systems, :slug
    remove_index :programs, :slug
  end
end
