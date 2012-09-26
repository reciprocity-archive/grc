class CreateObjectPeople < ActiveRecord::Migration
  class BizProcessPerson < ActiveRecord::Base
  end
  class SystemPerson < ActiveRecord::Base
  end

  def change
    create_table :object_people do |t|
      t.string :role
      t.text :notes
      t.references :person, :null => false
      t.references :personable, :polymorphic => true, :null => false
      t.references :modified_by
      t.timestamps
    end

    # Add index on object_people[personable_type, personable_id]
    add_index :object_people, [:personable_type, :personable_id]

    ObjectPerson.reset_column_information

    # Copy/move items from biz_process_people and system_people to object_people

    BizProcessPerson.reset_column_information
    BizProcessPerson.all.each do |bpp|
      if bpp.person && bpp.biz_process
        ObjectPerson.create!(
          :person => bpp.person,
          :personable => bpp.biz_process,
          :role => bpp.role,
          :modified_by_id => bpp.modified_by_id,
          :created_at => bpp.created_at,
          :updated_at => bpp.updated_at
        )
      end
    end

    SystemPerson.reset_column_information
    SystemPerson.all.each do |sp|
      if sp.person && sp.system
        ObjectPerson.create!(
          :person => sp.person,
          :personable => sp.system,
          :role => sp.role,
          :modified_by_id => sp.modified_by_id,
          :created_at => sp.created_at,
          :updated_at => sp.updated_at
        )
      end
    end

    # Remove biz_process_people and system_people
    #drop_table :biz_process_people
    #drop_table :system_people
  end
end
