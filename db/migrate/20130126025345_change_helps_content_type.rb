class ChangeHelpsContentType < ActiveRecord::Migration
  def up
    change_column :helps, :content, :text, :limit => nil
  end

  def down
    change_column :helps, :content, :string
  end
end
