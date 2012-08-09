class AddOptionReferences < ActiveRecord::Migration
  def up
    change_table :controls do |t|
      t.references :type
      t.references :kind
      t.references :means
    end

    change_table :systems do |t|
      t.references :type
    end
  end

  def down
    change_table :controls do |t|
      t.remove :type_id
      t.remove :kind_id
      t.remove :means_id
    end

    change_table :systems do |t|
      t.remove :type_id
    end
  end
end
