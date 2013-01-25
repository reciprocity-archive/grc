class RemoveInvalidRiskyAttributes < ActiveRecord::Migration
  def up
    RiskyAttribute.where(:type_string => nil).each do |ra|
      ra.destroy
    end

    RiskyAttribute.where(:type_string => "").each do |ra|
      ra.destroy
    end

    RiskyAttribute.where(:type_string => "Org Group").each do |ra|
      ra.update_attribute(:type_string, "OrgGroup")
    end

    RiskyAttribute.where(:type_string => "Data Asset").each do |ra|
      ra.update_attribute(:type_string, "DataAsset")
    end

    Relationship.where(:destination_type => 'RiskyAttribute').each do |rel|
      if rel.destination.type_string != rel.source_type
        rel.destroy
      end
    end
  end

  def down
  end
end
