class AddAssertionsToControls < ActiveRecord::Migration
  def change
    change_table :controls do |t|
      t.boolean :fraud_related
      t.boolean :key_control
      t.boolean :active
    end
  end
end
