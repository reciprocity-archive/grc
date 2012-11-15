class CreateHelps < ActiveRecord::Migration
  def change
    create_table :helps do |t|
      t.string :slug
      t.string :content

      t.timestamps
    end
  end
end
