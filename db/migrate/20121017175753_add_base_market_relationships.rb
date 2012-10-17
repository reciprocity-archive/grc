class AddBaseMarketRelationships < ActiveRecord::Migration
  def up
    new_relationship_types = [
      # Relationship types are in alphabetical order!
      {
        :relationship_type => 'market_contains_a_market',
        :description => "Markets can have submarkets.",
        :forward_phrase =>"containing",
        :backward_phrase => "contained by"
      },
      {
        :relationship_type => 'market_is_dependent_on_location',
        :description => "Markets can be dependent on a location.",
        :forward_phrase =>"dependent on",
        :backward_phrase => "necessary for"
      },
      {
        :relationship_type => 'org_group_has_province_over_market',
        :description => "Org groups have province over market.",
        :forward_phrase =>"with province over",
        :backward_phrase => "overseen by"
      },
      {
        :relationship_type => 'product_is_sold_into_market',
        :description => "Products are sold into markets.",
        :forward_phrase =>"sold into",
        :backward_phrase => "targeted by"
      }
    ]

    new_relationship_types.each do |rt|
      record = RelationshipType.find_or_create_by_relationship_type(rt[:relationship_type])
      record.update_attributes(rt, :without_protection => true)
      record.save
    end
  end

  def down
  end
end
