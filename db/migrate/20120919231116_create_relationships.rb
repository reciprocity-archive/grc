class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.references :source, :polymorphic => true, :null => false
      t.references :destination, :polymorphic => true, :null => false
      t.references :modified_by
      t.string :relationship_type_id
      t.timestamps
    end

    add_index :relationships, [:source_type]
    add_index :relationships, [:source_id]
    add_index :relationships, [:destination_type]
    add_index :relationships, [:destination_id]
    add_index :relationships, [:relationship_type_id]
  end
end
