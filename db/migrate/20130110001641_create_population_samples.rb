class CreatePopulationSamples < ActiveRecord::Migration
  def change
    create_table :population_samples do |t|
      t.references :response
      t.references :population_document
      t.integer :population
      t.references :sample_worksheet_document
      t.integer :samples
      t.references :sample_evidence_document

      t.references :modified_by
      t.timestamps
    end

    remove_column :responses, :population_document_id
    remove_column :responses, :population
    remove_column :responses, :sample_worksheet_document_id
    remove_column :responses, :samples
    remove_column :responses, :sample_evidence_document_id
  end
end
