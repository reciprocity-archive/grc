class RemovePbcListsColumns < ActiveRecord::Migration
  def up
    change_table :pbc_lists do |t|
      t.remove :title
      t.remove :description
      t.remove :audit_firm
      t.remove :audit_lead
      t.remove :notes
      t.remove :list_import_date
      t.remove :status
    end
  end

  def down
  end
end
