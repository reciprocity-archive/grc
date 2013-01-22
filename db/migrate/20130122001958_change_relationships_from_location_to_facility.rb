class ChangeRelationshipsFromLocationToFacility < ActiveRecord::Migration
  def up
    Relationship.where(:source_type => 'Location').all.each do |rel|
      rel.update_attribute(:source_type, 'Facility')
    end
    Relationship.where(:destination_type => 'Location').all.each do |rel|
      rel.update_attribute(:destination_type, 'Facility')
    end
  end

  def down
    Relationship.where(:source_type => 'Facility').all.each do |rel|
      rel.update_attribute(:source_type, 'Location')
    end
    Relationship.where(:destination_type => 'Facility').all.each do |rel|
      rel.update_attribute(:destination_type, 'Location')
    end
  end
end
