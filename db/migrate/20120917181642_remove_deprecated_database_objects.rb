class RemoveDeprecatedDatabaseObjects < ActiveRecord::Migration
  def up
    # BizProcess is now a subset/type of System
    # - data migration happened in 20120723223448_copy_biz_processes_to_systems.rb
    drop_table :biz_process_controls
    drop_table :biz_process_documents
    drop_table :biz_process_people
    drop_table :biz_process_sections
    drop_table :biz_process_systems
    drop_table :biz_processes

    # Business Areas will be Entity objects
    # - no data migration because there is no way to create BusinessArea objects
    #   via the new interface, so only seeded objects exist in production
    remove_column :controls, :business_area_id
    drop_table :business_areas

    # DocumentDescriptors moved into Option set
    # - no data migration because there is no way to create DDescriptor objects
    #   via the new interface, so only seeded objects exist in production
    remove_column :documents, :document_descriptor_id
    drop_table :control_document_descriptors
    drop_table :document_descriptors

    # Document relations are now polymorphic via ObjectDocument
    # - data migration happened in 20120717173115_create_object_documents.rb
    remove_column :programs, :source_document_id
    remove_column :programs, :source_website_id
    drop_table :document_system_controls
    drop_table :document_systems

    # Person relations are now polymorphic via ObjectPeople
    # - data migration happened in 20120717225437_create_object_people.rb
    drop_table :system_people

    # TestResults will be represented by Requests/Tests/Verifications
    # - no data migration because there is no way to create TestResult objects
    #   via the new interface, so no objects exist in production
    remove_column :controls, :test_result_id
    drop_table :test_results

    # Unused/unpopulated columns which will be changed to use Option table or
    # additional tables
    remove_column :controls, [:is_key, :fraud_related, :technical, :assertion]
    remove_column :documents, [:reviewed, :good]
    remove_column :system_controls, [:ticket, :test_why, :test_impact, :test_recommendation]

    # Infrastructure may have real data -- migrate data to Option table and
    # remove in future migration
    #remove_column :systems, [:infrastructure]
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't recover lost information"
  end
end
