class AddPopulationSampleFieldsToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :population_document_id, :integer
    add_column :responses, :population, :integer
    add_column :responses, :sample_worksheet_document_id, :integer
    add_column :responses, :samples, :integer
    add_column :responses, :sample_evidence_document_id, :integer
  end
end
