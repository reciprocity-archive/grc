class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.references :request
      t.references :system
      t.string :status
      t.references :modified_by
      t.timestamps
    end
  end
end
