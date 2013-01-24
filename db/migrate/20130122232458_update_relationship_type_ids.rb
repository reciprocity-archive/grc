class UpdateRelationshipTypeIds < ActiveRecord::Migration
  RELATIONSHIP_TYPE_NAME_CHANGES = [
    [:program_is_relevant_to_org_group,     :program_applies_to_org_group],
    [:program_is_relevant_to_product,       :program_applies_to_product],
    [:program_is_relevant_to_facility,      :program_applies_to_facility],

    [:org_group_has_province_over_product,  :org_group_is_responsible_for_org_group],
    [:org_group_has_province_over_facility, :org_group_is_responsible_for_facility],
    [:org_group_has_province_over_market,   :org_group_is_responsible_for_market],
    [:org_group_is_dependent_on_facility,   :org_group_relies_upon_facility],
    [:org_group_is_dependent_on_org_group,  :org_group_relies_upon_org_group],

    [:product_is_dependent_on_facility,     :product_relies_upon_facility],
    [:product_is_dependent_on_product,      :product_relies_upon_product],

    [:facility_is_dependent_on_facility,    :facility_relies_upon_facility],

    [:market_is_dependent_on_facility,      :market_relies_upon_facility],
    [:market_contains_a_market,             :market_includes_market],
  ]

  def change_relationship_type_id(old_name, new_name)
    rel_type = RelationshipType.where(:relationship_type => old_name.to_s).first

    if rel_type
      rel_type.relationship_type = new_name.to_s
      rel_type.save!
    end

    Relationship.where(:relationship_type_id => old_name.to_s).all.each do |rel|
      rel.relationship_type_id = new_name.to_s
      rel.save!
    end
  end

  def up
    transaction do
      RELATIONSHIP_TYPE_NAME_CHANGES.each do |old_name, new_name|
        change_relationship_type_id(old_name, new_name)
      end
    end
  end

  def down
    transaction do
      RELATIONSHIP_TYPE_NAME_CHANGES.each do |old_name, new_name|
        change_relationship_type_id(new_name, old_name)
      end
    end
  end
end
