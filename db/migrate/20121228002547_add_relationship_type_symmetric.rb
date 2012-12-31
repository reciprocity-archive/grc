class AddRelationshipTypeSymmetric < ActiveRecord::Migration
  def change
    add_column :relationship_types, :symmetric, :boolean, :default => false
  end
end
