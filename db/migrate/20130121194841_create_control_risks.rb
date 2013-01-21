class CreateControlRisks < ActiveRecord::Migration
  def change
    create_table :control_risks do |t|
      t.references :control, :null => false
      t.references :risk, :null => false

      t.references :modified_by
      t.timestamps
    end
  end
end
