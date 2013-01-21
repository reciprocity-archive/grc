class CreateRiskRiskyAttributes < ActiveRecord::Migration
  def change
    create_table :risk_risky_attributes do |t|
      t.references :risk, :null => false
      t.references :risky_attribute, :null => false

      t.references :modified_by
      t.timestamps
    end
  end
end
