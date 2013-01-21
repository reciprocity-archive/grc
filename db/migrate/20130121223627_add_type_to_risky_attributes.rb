class AddTypeToRiskyAttributes < ActiveRecord::Migration
  def change
    change_table :risky_attributes do |t|
      t.string :type_string
    end
  end
end
