class CreateObjectDocuments < ActiveRecord::Migration
  class BizProcessDocument < ActiveRecord::Base
  end
  class DocumentSystem < ActiveRecord::Base
  end
  class DocumentSystemControl < ActiveRecord::Base
  end

  def change
    create_table :object_documents do |t|
      t.string :role
      t.text :notes
      t.references :document, :null => false
      t.references :documentable, :polymorphic => true, :null => false
      t.references :modified_by
      t.timestamps
    end

    # Add index on object_documents[documentable_type, documentable_id]
    add_index :object_documents, [:documentable_type, :documentable_id]

    # Copy items from biz_process_documents, document_systems,
    #   document_system_controls, and programs to object_documents
    ObjectDocument.reset_column_information

    BizProcessDocument.reset_column_information
    BizProcessDocument.all.each do |bpd|
      if bpd.policy && bpd.biz_process
        ObjectDocument.create!(
          :document => bpd.policy,
          :documentable => bpd.biz_process,
          :modified_by_id => bpd.modified_by_id,
          :created_at => bpd.created_at,
          :updated_at => bpd.updated_at
        )
      end
    end

    DocumentSystem.reset_column_information
    DocumentSystem.all.each do |ds|
      if ds.document && ds.system
        ObjectDocument.create!(
          :document => ds.document,
          :documentable => ds.system,
          :modified_by_id => ds.modified_by_id,
          :created_at => ds.created_at,
          :updated_at => ds.updated_at
        )
      end
    end

    DocumentSystemControl.reset_column_information
    DocumentSystemControl.all.each do |ds|
      if ds.evidence && ds.system_control
        ObjectDocument.create!(
          :document => ds.evidence,
          :documentable => ds.system_control,
          :modified_by_id => ds.modified_by_id,
          :created_at => ds.created_at,
          :updated_at => ds.updated_at
        )
      end
    end

    Program.reset_column_information
    Program.all.each do |p|
      if p.source_document
        ObjectDocument.create!(
          :document => p.source_document,
          :documentable => p,
          :role => 'source_document',
          :modified_by_id => p.modified_by_id,
          :created_at => p.created_at,
          :updated_at => p.updated_at
        )
      end

      if p.source_website
        ObjectDocument.create!(
          :document => p.source_website,
          :documentable => p,
          :role => 'source_website',
          :modified_by_id => p.modified_by_id,
          :created_at => p.created_at,
          :updated_at => p.updated_at
        )
      end
    end

    # Remove biz_process_documents, document_systems and document_system_controls
    #drop_table :biz_process_documents
    #drop_table :document_systems
    #drop_table :document_system_controls

    # Remove document columns from Program
    #change_table :programs do |t|
    #  t.remove :source_document_id
    #  t.remove :source_website_id
    #end
  end
end
