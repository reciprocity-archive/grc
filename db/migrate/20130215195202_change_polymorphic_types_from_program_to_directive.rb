class ChangePolymorphicTypesFromProgramToDirective < ActiveRecord::Migration
  RELATIONSHIP_TYPE_NAME_CHANGES = [
    [:program_applies_to_data_asset, :directive_applies_to_data_asset],
    [:program_applies_to_facility,   :directive_applies_to_facility],
    [:program_applies_to_market,     :directive_applies_to_market],
    [:program_applies_to_org_group,  :directive_applies_to_org_group],
    [:program_applies_to_product,    :directive_applies_to_product],
    [:program_applies_to_project,    :directive_applies_to_project],
  ]

  OPTION_ROLE_CHANGES = [
    [:program_kind, :directive_kind]
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

  def change_polymorphic_types(old_type, new_type)
    Relationship.where(:source_type => old_type).all.each do |rel|
      rel.update_attribute(:source_type, new_type)
    end
    Relationship.where(:destination_type => old_type).all.each do |rel|
      rel.update_attribute(:destination_type, new_type)
    end

    Categorization.where(:categorizable_type => old_type).all.each do |o|
      o.update_attribute(:categorizable_type, new_type)
    end
    ObjectPerson.where(:personable_type => old_type).all.each do |o|
      o.update_attribute(:personable_type, new_type)
    end
    ObjectDocument.where(:documentable_type => old_type).all.each do |o|
      o.update_attribute(:documentable_type, new_type)
    end

    Version.where(:item_type => old_type).all.each do |o|
      o.update_attribute(:item_type, new_type)
    end
  end

  def change_option_roles(old_role, new_role)
    Option.where(:role => old_role).all.each do |o|
      o.update_attribute(:role, new_role)
    end
  end

  def up
    transaction do
      change_polymorphic_types('Program', 'Directive')

      OPTION_ROLE_CHANGES.each do |old_role, new_role|
        change_option_roles(old_role, new_role)
      end

      RELATIONSHIP_TYPE_NAME_CHANGES.each do |old_name, new_name|
        change_relationship_type_id(old_name, new_name)
      end
    end
  end

  def down
    transaction do
      change_polymorphic_types('Directive', 'Program')

      OPTION_ROLE_CHANGES.each do |old_role, new_role|
        change_option_roles(new_role, old_role)
      end

      RELATIONSHIP_TYPE_NAME_CHANGES.each do |old_name, new_name|
        change_relationship_type_id(new_name, old_name)
      end
    end
  end
end
