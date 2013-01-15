class FixRiskyAttributeRelationships < ActiveRecord::Migration
  RELATIONSHIP_TYPE_NAME_CHANGES = [
    [ :risky_attribute_is_an_attribute_of_org_group,  :org_group_has_risky_attribute ],
    [ :risky_attribute_is_an_attribute_of_product,    :product_has_risky_attribute ],
    [ :risky_attribute_is_an_attribute_of_location,   :location_has_risky_attribute ],
    [ :risky_attribute_is_an_attribute_of_market,     :market_has_risky_attribute ],
  ]

  def up
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
  end

  def down
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
  end
end
