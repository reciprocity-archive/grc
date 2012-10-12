class CreateOrgGroups < ActiveRecord::Migration
  def change
    create_table :org_groups do |t|
      t.string :slug
      t.string :title
      t.text   :description
      t.string :url

      t.references :modified_by
      t.datetime :start_date
      t.datetime :stop_date

      t.timestamps
    end
  end
end
