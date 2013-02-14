class ChangePolymorphicTypesFromLocationToFacility < ActiveRecord::Migration
  def up
    ObjectPerson.where(:personable_type => 'Location').all.each do |o|
      o.update_attribute(:personable_type, 'Facility')
    end
    ObjectDocument.where(:documentable_type => 'Location').all.each do |o|
      o.update_attribute(:documentable_type, 'Facility')
    end
    Version.where(:item_type => 'Location').all.each do |o|
      o.update_attribute(:item_type, 'Facility')
    end
  end

  def down
    ObjectPerson.where(:personable_type => 'Facility').all.each do |o|
      o.update_attribute(:personable_type, 'Location')
    end
    ObjectDocument.where(:documentable_type => 'Facility').all.each do |o|
      o.update_attribute(:documentable_type, 'Location')
    end
    Version.where(:item_type => 'Facility').all.each do |o|
      o.update_attribute(:item_type, 'Location')
    end
  end
end
