class RenameLocationsToFacilities < ActiveRecord::Migration
  RELATIONSHIP_TYPE_NAME_CHANGES = [
    ["location_has_process",                 "facility_has_process"],
    ["location_has_risky_attribute",         "facility_has_risky_attribute"],
    ["location_is_dependent_on_location",    "facility_is_dependent_on_facility"],
    ["market_is_dependent_on_location",      "market_is_dependent_on_facility"],
    ["org_group_has_province_over_location", "org_group_has_province_over_facility"],
    ["org_group_is_dependent_on_location",   "org_group_is_dependent_on_facility"],
    ["product_is_dependent_on_location",     "product_is_dependent_on_facility"],
    ["program_is_relevant_to_location",      "program_is_relevant_to_facility"]
  ]

  OPTION_TYPE_NAME_CHANGES = [
    ["location_type", "facility_type"],
    ["location_kind", "facility_kind"],
  ]

  def up
    rename_table :locations, :facilities

    RELATIONSHIP_TYPE_NAME_CHANGES.each do |old_name, new_name|
      rel_type = RelationshipType.where(:relationship_type => old_name).first

      if rel_type
        rel_type.relationship_type = new_name
        rel_type.save
      end

      Relationship.where(:relationship_type_id => old_name).all.each do |rel|
        rel.relationship_type_id = new_name
        rel.save
      end
    end

    OPTION_TYPE_NAME_CHANGES.each do |old_name, new_name|
      Option.where(:role => old_name).all.each do |o|
        o.role = new_name
      end
    end
  end

  def down
    rename_table :facilities, :locations

    RELATIONSHIP_TYPE_NAME_CHANGES.each do |old_name, new_name|
      rel_type = RelationshipType.where(:relationship_type => new_name).first

      if rel_type
        rel_type.relationship_type = old_name
        rel_type.save
      end

      Relationship.where(:relationship_type_id => new_name).all.each do |rel|
        rel.relationship_type_id = old_name
        rel.save
      end
    end

    OPTION_TYPE_NAME_CHANGES.each do |old_name, new_name|
      Option.where(:role => new_name).all.each do |o|
        o.role = old_name
      end
    end
  end
end
