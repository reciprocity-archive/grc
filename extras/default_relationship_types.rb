module DefaultRelationshipTypes
  RELATIONSHIP_TYPES = [
    # Relationship types are in alphabetical order!
    {
      :relationship_type => 'location_is_dependent_on_location',
      :description => "Locations can be dependent on each other.",
      :forward_phrase =>"dependent on",
      :backward_phrase => "necessary for"
    },
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
      :relationship_type => 'org_group_has_province_over_location',
      :description => "Org groups have province over locations.",
      :forward_phrase =>"with province over",
      :backward_phrase => "overseen by"
    },
    {
      :relationship_type => 'org_group_has_province_over_market',
      :description => "Org groups have province over market.",
      :forward_phrase =>"with province over",
      :backward_phrase => "overseen by"
    },
    {
      :relationship_type => 'org_group_has_province_over_product',
      :description => "Org groups have province over products.",
      :forward_phrase =>"with province over",
      :backward_phrase => "overseen by"
    },
    {
      :relationship_type => 'org_group_is_affiliated_with_org_group',
      :description => "Org groups can be affiliated with each other.",
      :forward_phrase =>"affiliated with",
      :backward_phrase => "affiliated with"
    },
    {
      :relationship_type => 'org_group_is_dependent_on_location',
      :description => "Org groups can be dependent on locations.",
      :forward_phrase =>"dependent on",
      :backward_phrase => "necessary for"
    },
    {
      :relationship_type => 'product_is_affiliated_with_product',
      :description => "Products can be affiliated with each other.",
      :forward_phrase =>"affiliated with",
      :backward_phrase => "affiliated with"
    },
    {
      :relationship_type => 'product_is_dependent_on_location',
      :description => "Products can be dependent on locations.",
      :forward_phrase =>"dependent on",
      :backward_phrase => "necessary for"
    },
    {
      :relationship_type => 'product_is_dependent_on_product',
      :description => "Products can be dependent on products.",
      :forward_phrase =>"dependent on",
      :backward_phrase => "necessary for"
    },
    {
      :relationship_type => 'product_is_sold_into_market',
      :description => "Products are sold into markets.",
      :forward_phrase =>"sold into",
      :backward_phrase => "targeted by"
    },
    {
      :relationship_type => 'program_is_relevant_to_location',
      :description => "Programs that are relevant to this location.",
      :forward_phrase =>"relevant to",
      :backward_phrase => "within scope of"
    },
    {
      :relationship_type => 'program_is_relevant_to_org_group',
      :description => "Programs that are relevant to this org group.",
      :forward_phrase =>"relevant to",
      :backward_phrase => "within scope of"
    },
    {
      :relationship_type => 'program_is_relevant_to_product',
      :description => "Programs that are relevant to this product.",
      :forward_phrase =>"relevant to",
      :backward_phrase => "within scope of"
    }
  ]

  def self.create_and_update
    RELATIONSHIP_TYPES.each do |rt|
      record = RelationshipType.find_or_create_by_relationship_type(rt[:relationship_type])
      record.update_attributes(rt, :without_protection => true)
      record.save
    end
  end

  def self.create_only
    RELATIONSHIP_TYPES.each do |rt|
      record = RelationshipType.first_or_create!(rt, :without_protection => true)
      record.save
    end
  end
end
