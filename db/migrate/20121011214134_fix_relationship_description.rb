class FixRelationshipDescription < ActiveRecord::Migration
  def up
    rename_column :relationship_types, :forward_short_description, :forward_phrase
    rename_column :relationship_types, :backward_short_description, :backward_phrase
  end

  def down
    rename_column :relationship_types, :forward_phrase, :forward_short_description
    rename_column :relationship_types, :backward_phrase, :backward_short_description
  end
end
