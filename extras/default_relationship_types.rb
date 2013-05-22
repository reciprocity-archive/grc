module DefaultRelationshipTypes

  RELATIONSHIP_TYPES = {
    :data_asset_has_process => {
      :source_type => "DataAsset",
      :target_type => "Process",
      :forward_phrase => "has",
      :reverse_phrase => "is a process for",
      :forward_description => "This data asset relies upon the following processes.",
      :reverse_description => "This process supports the following data assets."
    },
    :data_asset_relies_upon_data_asset => {
      :source_type => "DataAsset",
      :target_type => "DataAsset",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This data asset relies upon the following data assets.",
      :reverse_description => "This data asset supports the following data assets."
    },
    :data_asset_relies_upon_facility => {
      :source_type => "DataAsset",
      :target_type => "Facility",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This data asset relies upon the following facilities.",
      :reverse_description => "This facility supports the following data assets."
    },
    :data_asset_relies_upon_system => {
      :source_type => "DataAsset",
      :target_type => "System",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This data asset relies upon the following systems.",
      :reverse_description => "This system supports the following data assets."
    },
    :facility_has_process => {
      :source_type => "Facility",
      :target_type => "Process",
      :forward_phrase => "has",
      :reverse_phrase => "is a process for",
      :forward_description => "This facility relies upon the following processes.",
      :reverse_description => "This process supports the following facilities."
    },
    :facility_relies_upon_data_asset => {
      :source_type => "Facility",
      :target_type => "DataAsset",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This facility relies upon the following data assets.",
      :reverse_description => "This data asset supports the following facilities."
    },
    :facility_relies_upon_facility => {
      :source_type => "Facility",
      :target_type => "Facility",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This facility relies upon the following facilities.",
      :reverse_description => "This facility supports the following facilities."
    },
    :facility_relies_upon_system => {
      :source_type => "Facility",
      :target_type => "System",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This facility relies upon the following systems.",
      :reverse_description => "This system supports the following facilities."
    },
    :market_has_process => {
      :source_type => "Market",
      :target_type => "Process",
      :forward_phrase => "has",
      :reverse_phrase => "is a process for",
      :forward_description => "This market relies upon the following processes.",
      :reverse_description => "This process supports the following markets."
    },
    :market_includes_market => {
      :source_type => "Market",
      :target_type => "Market",
      :forward_phrase => "includes",
      :reverse_phrase => "is included in",
      :forward_description => "This market includes the following markets.",
      :reverse_description => "This market is included in the following markets."
    },
    :market_relies_upon_data_asset => {
      :source_type => "Market",
      :target_type => "DataAsset",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This market relies upon the following data assets.",
      :reverse_description => "This data asset supports the following markets."
    },
    :market_relies_upon_facility => {
      :source_type => "Market",
      :target_type => "Facility",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This market relies upon the following facilities.",
      :reverse_description => "This facility supports the following markets."
    },
    :market_relies_upon_system => {
      :source_type => "Market",
      :target_type => "System",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This market relies upon the following systems.",
      :reverse_description => "This system supports the following markets."
    },
    :org_group_has_process => {
      :source_type => "OrgGroup",
      :target_type => "Process",
      :forward_phrase => "has",
      :reverse_phrase => "is a process for",
      :forward_description => "This org group relies upon the following processes.",
      :reverse_description => "This process supports the following org groups."
    },
    :org_group_is_affiliated_with_org_group => {
      :source_type => "OrgGroup",
      :target_type => "OrgGroup",
      :symmetric => true,
      :forward_phrase => "is affiliated/collaborates with",
      :reverse_phrase => "is affiliated/collaborates with",
      :forward_description => "This org group is affiliated/collaborates with the following org groups.",
      :reverse_description => "This org group is affiliated/collaborates with the following org groups."
    },
    :org_group_is_responsible_for_data_asset => {
      :source_type => "OrgGroup",
      :target_type => "DataAsset",
      :forward_phrase => "is responsible for",
      :reverse_phrase => "is overseen by",
      :forward_description => "This org group is responsible for the following data assets.",
      :reverse_description => "This data asset is overseen by the following org groups."
    },
    :org_group_is_responsible_for_facility => {
      :source_type => "OrgGroup",
      :target_type => "Facility",
      :forward_phrase => "is responsible for",
      :reverse_phrase => "is overseen by",
      :forward_description => "This org group is responsible for the following facilities.",
      :reverse_description => "This facility is overseen by the following org groups."
    },
    :org_group_is_responsible_for_market => {
      :source_type => "OrgGroup",
      :target_type => "Market",
      :forward_phrase => "is responsible for",
      :reverse_phrase => "is overseen by",
      :forward_description => "This org group is responsible for the following markets.",
      :reverse_description => "This market is overseen by the following org groups."
    },
    :org_group_is_responsible_for_org_group => {
      :source_type => "OrgGroup",
      :target_type => "OrgGroup",
      :forward_phrase => "is responsible for",
      :reverse_phrase => "is overseen by",
      :forward_description => "This org group is responsible for the following org groups.",
      :reverse_description => "This org group is overseen by the following org groups."
    },
    :org_group_is_responsible_for_process => {
      :source_type => "OrgGroup",
      :target_type => "Process",
      :forward_phrase => "is responsible for",
      :reverse_phrase => "is overseen by",
      :forward_description => "This org group is responsible for the following processes.",
      :reverse_description => "This process is overseen by the following org groups."
    },
    :org_group_is_responsible_for_product => {
      :source_type => "OrgGroup",
      :target_type => "Product",
      :forward_phrase => "is responsible for",
      :reverse_phrase => "is overseen by",
      :forward_description => "This org group is responsible for the following products.",
      :reverse_description => "This product is overseen by the following org groups."
    },
    :org_group_is_responsible_for_project => {
      :source_type => "OrgGroup",
      :target_type => "Project",
      :forward_phrase => "is responsible for",
      :reverse_phrase => "is overseen by",
      :forward_description => "This org group is responsible for the following projects.",
      :reverse_description => "This project is overseen by the following org groups."
    },
    :org_group_is_responsible_for_system => {
      :source_type => "OrgGroup",
      :target_type => "System",
      :forward_phrase => "is responsible for",
      :reverse_phrase => "is overseen by",
      :forward_description => "This org group is responsible for the following systems.",
      :reverse_description => "This system is overseen by the following org groups."
    },
    :org_group_relies_upon_data_asset => {
      :source_type => "OrgGroup",
      :target_type => "DataAsset",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This org group relies upon the following data assets.",
      :reverse_description => "This data asset supports the following org groups."
    },
    :org_group_relies_upon_facility => {
      :source_type => "OrgGroup",
      :target_type => "Facility",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This org group relies upon the following facilities.",
      :reverse_description => "This facility supports the following org groups."
    },
    :org_group_relies_upon_org_group => {
      :source_type => "OrgGroup",
      :target_type => "OrgGroup",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This org group relies upon the following org groups.",
      :reverse_description => "This org group supports the following org groups."
    },
    :org_group_relies_upon_system => {
      :source_type => "OrgGroup",
      :target_type => "System",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This org group relies upon the following systems.",
      :reverse_description => "This system supports the following org groups."
    },
    :product_has_process => {
      :source_type => "Product",
      :target_type => "Process",
      :forward_phrase => "has",
      :reverse_phrase => "is a process for",
      :forward_description => "This product relies upon the following processes.",
      :reverse_description => "This process supports the following products."
    },
    :product_is_affiliated_with_product => {
      :source_type => "Product",
      :target_type => "Product",
      :symmetric => true,
      :forward_phrase => "is affiliated/collaborates with",
      :reverse_phrase => "is affiliated/collaborates with",
      :forward_description => "This product is affiliated/collaborates with the following products.",
      :reverse_description => "This product is affiliated/collaborates with the following products."
    },
    :product_is_sold_into_market => {
      :source_type => "Product",
      :target_type => "Market",
      :forward_phrase => "is sold into",
      :reverse_phrase => "is a market for",
      :forward_description => "This product is sold into the following markets.",
      :reverse_description => "This market is a market for the following products."
    },
    :product_relies_upon_data_asset => {
      :source_type => "Product",
      :target_type => "DataAsset",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This product relies upon the following data assets.",
      :reverse_description => "This data asset supports the following products."
    },
    :product_relies_upon_facility => {
      :source_type => "Product",
      :target_type => "Facility",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This product relies upon the following facilities.",
      :reverse_description => "This facility supports the following products."
    },
    :product_relies_upon_product => {
      :source_type => "Product",
      :target_type => "Product",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This product relies upon the following products.",
      :reverse_description => "This product supports the following products."
    },
    :product_relies_upon_system => {
      :source_type => "Product",
      :target_type => "System",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This product relies upon the following systems.",
      :reverse_description => "This system supports the following products."
    },
    :program_applies_to_data_asset => {
      :source_type => "Program",
      :target_type => "DataAsset",
      :forward_phrase => "applies to",
      :reverse_phrase => "is within scope of",
      :forward_description => "This program applies to the following data assets.",
      :reverse_description => "This data asset is within scope of the following programs."
    },
    :program_applies_to_facility => {
      :source_type => "Program",
      :target_type => "Facility",
      :forward_phrase => "applies to",
      :reverse_phrase => "is within scope of",
      :forward_description => "This program applies to the following facilities.",
      :reverse_description => "This facility is within scope of the following programs."
    },
    :program_applies_to_market => {
      :source_type => "Program",
      :target_type => "Market",
      :forward_phrase => "applies to",
      :reverse_phrase => "is within scope of",
      :forward_description => "This program applies to the following markets.",
      :reverse_description => "This market is within scope of the following programs."
    },
    :program_applies_to_org_group => {
      :source_type => "Program",
      :target_type => "OrgGroup",
      :forward_phrase => "applies to",
      :reverse_phrase => "is within scope of",
      :forward_description => "This program applies to the following org groups.",
      :reverse_description => "This org group is within scope of the following programs."
    },
    :program_applies_to_process => {
      :source_type => "Program",
      :target_type => "Process",
      :forward_phrase => "applies to",
      :reverse_phrase => "is within scope of",
      :forward_description => "This program applies to the following processes.",
      :reverse_description => "This process is within scope of the following programs."
    },
    :program_applies_to_product => {
      :source_type => "Program",
      :target_type => "Product",
      :forward_phrase => "applies to",
      :reverse_phrase => "is within scope of",
      :forward_description => "This program applies to the following products.",
      :reverse_description => "This product is within scope of the following programs."
    },
    :program_applies_to_project => {
      :source_type => "Program",
      :target_type => "Project",
      :forward_phrase => "applies to",
      :reverse_phrase => "is within scope of",
      :forward_description => "This program applies to the following projects.",
      :reverse_description => "This project is within scope of the following programs."
    },
    :program_applies_to_system => {
      :source_type => "Program",
      :target_type => "System",
      :forward_phrase => "applies to",
      :reverse_phrase => "is within scope of",
      :forward_description => "This program applies to the following systems.",
      :reverse_description => "This system is within scope of the following programs."
    },
    :project_has_process => {
      :source_type => "Project",
      :target_type => "Process",
      :forward_phrase => "has",
      :reverse_phrase => "is a process for",
      :forward_description => "This project relies upon the following processes.",
      :reverse_description => "This process supports the following projects."
    },
    :project_relies_upon_data_asset => {
      :source_type => "Project",
      :target_type => "DataAsset",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This project relies upon the following data assets.",
      :reverse_description => "This data asset supports the following projects."
    },
    :project_relies_upon_facility => {
      :source_type => "Project",
      :target_type => "Facility",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This project relies upon the following facilities.",
      :reverse_description => "This facility supports the following projects."
    },
    :project_relies_upon_system => {
      :source_type => "Project",
      :target_type => "System",
      :forward_phrase => "relies upon",
      :reverse_phrase => "supports",
      :forward_description => "This project relies upon the following systems.",
      :reverse_description => "This system supports the following projects."
    },
    :project_targets_data_asset => {
      :source_type => "Project",
      :target_type => "DataAsset",
      :forward_phrase => "targets",
      :reverse_phrase => "is targeted by",
      :forward_description => "This project targets the following data assets.",
      :reverse_description => "This data asset is targeted by the following projects."
    },
    :project_targets_facility => {
      :source_type => "Project",
      :target_type => "Facility",
      :forward_phrase => "targets",
      :reverse_phrase => "is targeted by",
      :forward_description => "This project targets the following facilities.",
      :reverse_description => "This facility is targeted by the following projects."
    },
    :project_targets_market => {
      :source_type => "Project",
      :target_type => "Market",
      :forward_phrase => "targets",
      :reverse_phrase => "is targeted by",
      :forward_description => "This project targets the following markets.",
      :reverse_description => "This market is targeted by the following projects."
    },
    :project_targets_org_group => {
      :source_type => "Project",
      :target_type => "OrgGroup",
      :forward_phrase => "targets",
      :reverse_phrase => "is targeted by",
      :forward_description => "This project targets the following org groups.",
      :reverse_description => "This org group is targeted by the following projects."
    },
    :project_targets_product => {
      :source_type => "Project",
      :target_type => "Product",
      :forward_phrase => "targets",
      :reverse_phrase => "is targeted by",
      :forward_description => "This project targets the following products.",
      :reverse_description => "This product is targeted by the following projects."
    },
    :risk_is_a_threat_to_data_asset => {
      :source_type => "Risk",
      :target_type => "DataAsset",
      :forward_phrase => "is a threat to",
      :reverse_phrase => "is vulnerable to",
      :forward_description => "This risk is a threat to the following data assets.",
      :reverse_description => "This data asset is vulnerable to the following risks."
    },
    :risk_is_a_threat_to_facility => {
      :source_type => "Risk",
      :target_type => "Facility",
      :forward_phrase => "is a threat to",
      :reverse_phrase => "is vulnerable to",
      :forward_description => "This risk is a threat to the following facilities.",
      :reverse_description => "This faciliy is vulnerable to the following risks."
    },
    :risk_is_a_threat_to_market => {
      :source_type => "Risk",
      :target_type => "Market",
      :forward_phrase => "is a threat to",
      :reverse_phrase => "is vulnerable to",
      :forward_description => "This risk is a threat to the following markets.",
      :reverse_description => "This market is vulnerable to the following risks."
    },
    :risk_is_a_threat_to_org_group => {
      :source_type => "Risk",
      :target_type => "OrgGroup",
      :forward_phrase => "is a threat to",
      :reverse_phrase => "is vulnerable to",
      :forward_description => "This risk is not a threat to the following org groups.",
      :reverse_description => "This org group is vulnerable to the following risks."
    },
    :risk_is_a_threat_to_process => {
      :source_type => "Risk",
      :target_type => "Process",
      :forward_phrase => "is a threat to",
      :reverse_phrase => "is vulnerable to",
      :forward_description => "This risk is a threat to the following processes.",
      :reverse_description => "This process is vulnerable to the following risks."
    },
    :risk_is_a_threat_to_product => {
      :source_type => "Risk",
      :target_type => "Product",
      :forward_phrase => "is a threat to",
      :reverse_phrase => "is vulnerable to",
      :forward_description => "This risk is a threat to the following products.",
      :reverse_description => "This product is vulnerable to the following risks."
    },
    :risk_is_a_threat_to_project => {
      :source_type => "Risk",
      :target_type => "Project",
      :forward_phrase => "is a threat to",
      :reverse_phrase => "is vulnerable to",
      :forward_description => "This risk is a threat to the following projects.",
      :reverse_description => "This project is vulnerable to the following risks."
    },
    :risk_is_a_threat_to_system => {
      :source_type => "Risk",
      :target_type => "System",
      :forward_phrase => "is a threat to",
      :reverse_phrase => "is vulnerable to",
      :forward_description => "This risk is a threat to the following systems.",
      :reverse_description => "This system is vulnerable to the following risks."
    },
  }

  def self.types
    types = HashWithIndifferentAccess.new
    RELATIONSHIP_TYPES.each do |k, rt|
      types[k] = rt.dup
      types[k][:relationship_type] = k.to_s
    end
    types
  end

  #def self.create_and_update
  #  # This will update existing relationships, useful if you have changed some of the
  #  # descriptions and phrases.
  #  RELATIONSHIP_TYPES.each do |rt|
  #    record = RelationshipType.find_or_create_by_relationship_type(rt[:relationship_type])
  #    record.update_attributes(rt, :without_protection => true)
  #    record.save
  #  end
  #end

  #def self.create_only
  #  # This will only create relationships that are missing, not update existing ones.
  #  RELATIONSHIP_TYPES.each do |rt|
  #    record = RelationshipType.first_or_create!(rt, :without_protection => true)
  #    record.save
  #  end
  #end

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
    :facility_is_dependent_on_facility => {
      :read => :forward,
      :meta_read => :backward,
    },
    :market_contains_a_market => {
      :read => :forward,
      :meta_read => :backward,
      :edit => :forward
    },
    :market_is_dependent_on_facility => {
      :meta_read => :both
    },
    :org_group_has_province_over_facility => {
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
    :org_group_is_dependent_on_facility => {
      :meta_read => :both
    },
    :product_is_affiliated_with_product => {
      :meta_read => :both
    },
    :product_is_dependent_on_facility => {
      :meta_read => :both
    },
    :product_is_dependent_on_product => {
      :meta_read => :both
    },
    :product_is_sold_into_market => {
      :meta_read => :both
    },
    :directive_includes_control => {
      :read => :forward,
      :meta_read => :backward,
      :edit => :forward
    },
    :directive_includes_section => {
      :read => :forward,
      :meta_read => :backward,
      :edit => :forward
    },
    :directive_is_relevant_to_facility => {
      :meta_read => :both
    },
    :directive_is_relevant_to_org_group => {
      :meta_read => :both
    },
    :directive_is_relevant_to_product => {
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

  PERSONABLE = [Directive, Section, Control, System,
                OrgGroup, Product, Facility]
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
