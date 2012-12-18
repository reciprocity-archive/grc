class CreateControlAssessments < ActiveRecord::Migration
  def change
    create_table :control_assessments do |t|
      t.references :pbc_list
      t.references :control
      t.string :control_version
      t.boolean :internal_tod, :default => nil, :null => true
      t.boolean :internal_toe, :default => nil, :null => true
      t.boolean :external_tod, :default => nil, :null => true
      t.boolean :external_toe, :default => nil, :null => true
      t.text :notes

      t.timestamps
    end
    add_index :control_assessments, :pbc_list_id
    add_index :control_assessments, :control_id
  end
end
