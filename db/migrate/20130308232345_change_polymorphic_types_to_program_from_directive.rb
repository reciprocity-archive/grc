class ChangePolymorphicTypesToProgramFromDirective < ActiveRecord::Migration
  RELATIONSHIP_TYPE_NAME_CHANGES = [
    [:directive_applies_to_data_asset, :program_applies_to_data_asset],
    [:directive_applies_to_facility,   :program_applies_to_facility],
    [:directive_applies_to_market,     :program_applies_to_market],
    [:directive_applies_to_org_group,  :program_applies_to_org_group],
    [:directive_applies_to_product,    :program_applies_to_product],
    [:directive_applies_to_project,    :program_applies_to_project],
  ]

  def up
    transaction do
      RELATIONSHIP_TYPE_NAME_CHANGES.each do |old_name, new_name|
        Relationship.where(:relationship_type_id => old_name.to_s).all.each do |rel|
          directive = Directive.where(:id => rel.source_id).first
          program = directive && directive.programs.first

          if program
            rel.relationship_type_id = new_name.to_s
            rel.source = program
            rel.save!
          else
            rel.destroy
          end
        end
      end
    end
  end

  def down
  end
end
