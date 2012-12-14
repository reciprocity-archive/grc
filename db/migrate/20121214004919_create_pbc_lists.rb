class CreatePbcLists < ActiveRecord::Migration
  def change
    create_table :pbc_lists do |t|
      t.references :audit_cycle
      t.string :title
      t.string :audit_firm
      t.string :audit_lead
      t.text :description
      t.datetime :list_import_date
      t.string :status
      t.text :notes
      t.references :modified_by
      t.timestamps
    end
  end
end
