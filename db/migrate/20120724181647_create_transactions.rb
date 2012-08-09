class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :title, :null => false
      t.text :description
      t.references :system
      t.references :modified_by
      t.timestamps
    end
  end
end
