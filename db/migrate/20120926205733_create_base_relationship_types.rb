class CreateBaseRelationshipTypes < ActiveRecord::Migration
  class RelationshipType < ActiveRecord::Base
    self.primary_key = 'relationship_type'
  end

  def up
    RelationshipType.create({:relationship_type => 'within_scope_of',
                              :description => 'The source is within the scope of the destination',
                              :forward_short_description => 'is within scope of',
                              :backward_short_description => 'is relevant to'}, :without_protection => true)

  end

  def down
    r = RelationshipType.find('within_scope_of')
    r.destroy

    # FIXME: In theory, should delete all existing relationships using those types as well.
  end
end
