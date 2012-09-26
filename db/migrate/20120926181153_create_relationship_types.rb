class CreateRelationshipTypes < ActiveRecord::Migration

  def change
    create_table :relationship_types, :id => false do |t|
      t.string :relationship_type
      t.string :description
      t.string :forward_short_description
      t.string :backward_short_description
      t.timestamps
    end
    
    add_index :relationship_types, :relationship_type, :unique => true
  end
end
