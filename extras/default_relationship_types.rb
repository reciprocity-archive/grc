module DefaultRelationshipTypes
  RELATIONSHIP_TYPES = [
    # This is a list of the default relationship types that can be created
    # in the relationship model. Right now, there is a standard naming convention
    # of "<source_type>_<preposition>_<destination_type>"
    #
    # The forward and backward phrases are primarily used in the Related Objects UI.
    #
    # Relationship types are in alphabetical order, please keep them that way.
    #
    # When adding new relationship types, be sure to either add them in a migration.
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
      :backward_phrase => "affiliated with",
      :symmetric => true
    },
    {
      :relationship_type => 'org_group_is_dependent_on_location',
      :description => "Org groups can be dependent on locations.",
      :forward_phrase =>"dependent on",
      :backward_phrase => "necessary for"
    },
    {
      :relationship_type => 'product_has_process',
      :description => "Products have processes.",
      :forward_phrase =>"has process",
      :backward_phrase => "is a process of"
    },
    {
      :relationship_type => 'product_is_affiliated_with_product',
      :description => "Products can be affiliated with each other.",
      :forward_phrase =>"affiliated with",
      :backward_phrase => "affiliated with",
      :symmetric => true
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

  def self.types
    types = HashWithIndifferentAccess.new
    RELATIONSHIP_TYPES.each do |rt|
      types[rt[:relationship_type]] = rt
    end
    types
  end

  def self.create_and_update
    # This will update existing relationships, useful if you have changed some of the
    # descriptions and phrases.
    RELATIONSHIP_TYPES.each do |rt|
      record = RelationshipType.find_or_create_by_relationship_type(rt[:relationship_type])
      record.update_attributes(rt, :without_protection => true)
      record.save
    end
  end

  def self.create_only
    # This will only create relationships that are missing, not update existing ones.
    RELATIONSHIP_TYPES.each do |rt|
      record = RelationshipType.first_or_create!(rt, :without_protection => true)
      record.save
    end
  end

  # RELATIONSHIP_ABILITIES is primarily used by the ability_graph (and related)
  # traversal functions, which are used primarily in the context of authorization.
  # The mapping is of a RelationshipType to the abilities that are allowed to traverse it,
  # and the direction that you are allowed to traverse for that ability.
  #
  # So,
  # :control_reachable_by_system => {
  #   :walk => :both,
  #   :run => :forward
  # }
  #
  # allows traversal in both directions when walking, but only from control => system when running.
  #
  # NOTE: this contains, in addition to the "real" relationships above,
  # "fake" relationships generated by doing graph traversal over traditional
  # ActiveRecord relations baked into the models.
  # NOTE: Make sure you also see the dynamically generated relationship abilities
  # below.


  RELATIONSHIP_ABILITIES = {
    :control_implemented_by_control => {
      :read => :forward,
      :meta_read => :backward
    },
    :control_implemented_by_system => {
      :read => :forward,
      :meta_read => :backward
    },
    :location_is_dependent_on_location => {
      :read => :forward,
      :meta_read => :backward,
    },
    :market_contains_a_market => {
      :read => :forward,
      :meta_read => :backward,
      :edit => :forward
    },
    :market_is_dependent_on_location => {
      :meta_read => :both
    },
    :org_group_has_province_over_location => {
      :read => :forward,
      :meta_read => :backward,
      :edit => :forward
    },
    :org_group_has_province_over_market => {
      :read => :forward,
      :meta_read => :backward,
      :edit => :forward
    },
    :org_group_has_province_over_product => {
      :read => :forward,
      :meta_read => :backward,
      :edit => :forward
    },
    :org_group_is_affiliated_with_org_group => {
      :read => :forward,
      :meta_read => :backward,
    },
    :org_group_is_dependent_on_location => {
      :meta_read => :both
    },
    :product_is_affiliated_with_product => {
      :meta_read => :both
    },
    :product_is_dependent_on_location => {
      :meta_read => :both
    },
    :product_is_dependent_on_product => {
      :meta_read => :both
    },
    :product_is_sold_into_market => {
      :meta_read => :both
    },
    :program_includes_control => {
      :read => :forward,
      :meta_read => :backward,
      :edit => :forward
    },
    :program_includes_section => {
      :read => :forward,
      :meta_read => :backward,
      :edit => :forward
    },
    :program_is_relevant_to_location => {
      :meta_read => :both
    },
    :program_is_relevant_to_org_group => {
      :meta_read => :both
    },
    :program_is_relevant_to_product => {
      :meta_read => :both
    },
    :section_implemented_by_system => {
      :read => :forward,
      :meta_read => :backward,
      :edit => :forward
    },
    :section_includes_section => {
      :read => :forward,
      :meta_read => :backward,
      :edit => :forward
    },
    :system_contains_system => {
      :read => :forward,
      :meta_read => :backward,
      :edit => :forward
    },
    :default => {
      # In general, we should explicitly specify traversal rules for relationships, so
      # this probably should always remain empty.
    }

  }

  PERSONABLE = [Program, Section, Control, System,
                OrgGroup, Product, Location]
  ['accountable','responsible', 'owner'].each do |role|
    PERSONABLE.each do |model|
      rtype = "person_#{role}_for_#{model.to_s.downcase}"
      RELATIONSHIP_ABILITIES[rtype.to_sym] = {
        :read => :forward,
        :meta_read => :backward,
        :edit => :forward
      }
    end
  end
end
