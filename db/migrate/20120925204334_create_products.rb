class CreateProducts < ActiveRecord::Migration
  def up
    create_table :products do |t|
      t.string :slug
      t.string :title
      t.text   :description
      t.string :url
      t.string :version
      t.references :type

      t.references :modified_by
      t.timestamps
    end
  end

  def down
  end
end
