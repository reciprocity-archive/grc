class AddDocumentOptionColumns < ActiveRecord::Migration
  def up
    change_table :documents do |t|
      t.text :description
      t.references :type
      t.references :kind
      t.references :year
      t.references :language
    end
  end

  def down
    change_table :documents do |t|
      t.remove :description
      t.remove :type_id
      t.remove :kind_id
      t.remove :year_id
      t.remove :language_id
    end
  end
end
