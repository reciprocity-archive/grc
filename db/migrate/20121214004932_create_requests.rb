class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.references :pbc_list
      t.references :type
      t.references :control
      t.string :pbc_control_code
      t.text :pbc_control_desc
      t.text :request
      t.text :test
      t.text :notes
      t.string :company_responsible
      t.string :auditor_responsible
      t.datetime :date_requested
      t.string :status
      t.references :modified_by
      t.timestamps
    end
  end
end
