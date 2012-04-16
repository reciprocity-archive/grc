class CreateInitialTables < ActiveRecord::Migration
  def up
    create_table :accounts do |t|
      t.string :username
      t.string :name
      t.string :surname
      t.string :email
      t.string :crypted_password
      t.string :role
      t.string :persistence_token

      t.belongs_to :modified_by
      t.timestamps
    end

    create_table :biz_process_control_objectives do |t|
      t.belongs_to :biz_process,       :null => false
      t.belongs_to :control_objective, :null => false

      t.belongs_to :modified_by
      t.timestamps
    end

    add_index :biz_process_control_objectives, :control_objective_id
    add_index :biz_process_control_objectives, :biz_process_id

    # Primary key
    add_index :biz_process_control_objectives,
      [:biz_process_id, :control_objective_id],
      :unique => true,
      :name => "index_biz_process_control_objectives_uniqueness"

    create_table :biz_process_controls do |t|
      t.integer :state, :null => false, :default => 1
      t.string  :ticket

      t.belongs_to :biz_process, :null => false
      t.belongs_to :control,     :null => false

      t.belongs_to :modified_by
      t.timestamps
    end

    add_index :biz_process_controls, :control_id
    add_index :biz_process_controls, :biz_process_id

    create_table :biz_process_documents do |t|
      t.belongs_to :biz_process, :null => false
      t.belongs_to :policy,      :null => false

      t.belongs_to :modified_by
      t.timestamps
    end

    add_index :biz_process_documents, :biz_process_id
    add_index :biz_process_documents, :policy_id

    add_index :biz_process_documents,
      [:biz_process_id, :policy_id],
      :unique => true

    # biz_process_people
    create_table :biz_process_people do |t|
      t.integer :role, :null => false, :default => 1

      t.belongs_to :person,      :null => false
      t.belongs_to :biz_process, :null => false

      t.belongs_to :modified_by
      t.timestamps
    end

    add_index :biz_process_people, :biz_process_id
    add_index :biz_process_people, :person_id

    create_table :biz_processes do |t|
      t.string :title, :null => false
      t.string :slug,  :null => false
      t.text   :description

      t.belongs_to :owner

      t.belongs_to :modified_by
      t.timestamps
    end

    add_index :biz_processes, :owner_id

    create_table :biz_process_systems do |t|
      t.belongs_to :biz_process, :null => false
      t.belongs_to :system,      :null => false

      t.belongs_to :modified_by
      t.timestamps
    end

    add_index :biz_process_systems, :biz_process_id
    add_index :biz_process_systems, :system_id

    add_index :biz_process_systems,
      [:biz_process_id, :system_id],
      :unique => true,
      :name => "index_biz_process_systems_uniqueness"

    create_table :business_areas do |t|
      t.string :title

      t.belongs_to :modified_by
      t.timestamps
    end

    create_table :control_control_objectives do |t|
      t.belongs_to :control,           :null => false
      t.belongs_to :control_objective, :null => false

      t.belongs_to :modified_by
      t.timestamps
    end

    add_index :control_control_objectives, :control_id
    add_index :control_control_objectives, :control_objective_id

    add_index :control_control_objectives,
      [:control_id, :control_objective_id],
      :unique => true,
      :name => "index_control_control_objectives_uniqueness"

    create_table :control_controls do |t|
      t.belongs_to :control,             :null => false
      t.belongs_to :implemented_control, :null => false

      t.belongs_to :modified_by
      t.timestamps
    end

    add_index :control_controls, :control_id
    add_index :control_controls, :implemented_control_id

    add_index :control_controls,
      [:control_id, :implemented_control_id],
      :unique => true,
      :name => "index_control_controls_uniqueness"

    create_table :control_document_descriptors do |t|
      t.belongs_to :control,             :null => false
      t.belongs_to :evidence_descriptor, :null => false

      t.belongs_to :modified_by
      t.timestamps
    end

    add_index :control_document_descriptors, :control_id
    add_index :control_document_descriptors, :evidence_descriptor_id

    add_index :control_document_descriptors,
      [:control_id, :evidence_descriptor_id],
      :unique => true,
      :name => "index_control_document_descriptors_uniqueness"

    create_table :control_objectives do |t|
      t.string :title,       :null => false
      t.string :slug,        :null => false
      t.text   :description

      t.belongs_to :regulation, :null => false

      t.belongs_to :modified_by
      t.timestamps
    end

    add_index :control_objectives, :regulation_id

    create_table :controls do |t|
      t.string :title,   :null => false
      t.string :slug,    :null => false

      t.boolean :is_key,         :null => false, :default => false
      t.text    :description
      t.integer :frequency
      t.integer :frequency_type,                 :default => 1
      t.boolean :fraud_related,  :null => false, :default => false
      t.boolean :technical,      :null => false, :default => true
      t.string  :assertion
      t.datetime :effective_at

      t.belongs_to :business_area
      t.belongs_to :regulation

      t.belongs_to :test_result

      t.belongs_to :modified_by
      t.timestamps
    end

    add_index :controls, :business_area_id
    add_index :controls, :regulation_id
    add_index :controls, :test_result_id

    create_table :cycles do |t|
      t.belongs_to :regulation, :null => false
      t.date :start_at
      t.boolean :complete, :null => false, :default => false

      t.belongs_to :modified_by
      t.timestamps
    end

    add_index :cycles, :regulation_id

    create_table :document_descriptors do |t|
      t.string :title
      t.text   :description

      t.belongs_to :modified_by
      t.timestamps
    end

    create_table :documents do |t|
      t.string :title
      t.string :link

      t.belongs_to :document_descriptor

      t.boolean :reviewed, :null => false, :default => false
      t.boolean :good,                     :default => true

      t.belongs_to :modified_by
      t.timestamps
    end

    add_index :documents, :document_descriptor_id

    create_table :document_system_controls do |t|
      t.belongs_to :evidence,       :null => false
      t.belongs_to :system_control, :null => false

      t.belongs_to :modified_by
      t.timestamps
    end

    add_index :document_system_controls, :evidence_id
    add_index :document_system_controls, :system_control_id

    add_index :document_system_controls,
      [:evidence_id, :system_control_id],
      :unique => true,
      :name => "index_document_system_controls_uniqueness"

    create_table :document_systems do |t|
      t.belongs_to :document, :null => false
      t.belongs_to :system,   :null => false

      t.belongs_to :modified_by
      t.timestamps
    end

    add_index :document_systems, :document_id
    add_index :document_systems, :system_id

    add_index :document_systems,
      [:document_id, :system_id],
      :unique => true,
      :name => "index_document_systems_uniqueness"

    # people
    create_table :people do |t|
      t.string :username, :null => false
      t.string :name

      t.belongs_to :modified_by
      t.timestamps
    end

    create_table :regulations do |t|
      t.string :title, :null => false
      t.string :slug,  :null => false
      t.text :description
      t.boolean :company, :null => false, :default => false

      t.belongs_to :source_document
      t.belongs_to :source_website

      t.belongs_to :modified_by
      t.timestamps
    end

    add_index :regulations, :source_document_id
    add_index :regulations, :source_website_id

    create_table :system_control_objectives do |t|
      t.integer :state, :null => false, :default => 1

      t.belongs_to :control_objective, :null => false
      t.belongs_to :system,            :null => false

      t.belongs_to :modified_by
      t.timestamps
    end

    create_table :system_controls do |t|
      t.integer :state, :null => false, :default => 1
      t.string  :ticket

      t.belongs_to :control, :null => false
      t.belongs_to :system,  :null => false
      t.belongs_to :cycle

      t.text :test_why
      t.text :test_impact
      t.text :test_recommendation

      t.belongs_to :modified_by
      t.timestamps
    end

    create_table :system_people do |t|
      t.integer :role, :null => false, :default => 1

      t.belongs_to :person, :null => false
      t.belongs_to :system, :null => false

      t.belongs_to :modified_by
      t.timestamps
    end

    create_table :systems do |t|
      t.string :title, :null => false
      t.string :slug,  :null => false
      t.boolean :infrastructure, :null => false
      t.text :description

      t.belongs_to :owner

      t.belongs_to :modified_by
      t.timestamps
    end

    create_table :test_results do |t|
      t.string :title, :null => false
      t.boolean :passed, :null => false, :default => false
      t.text :output

      t.belongs_to :modified_by
      t.timestamps
    end
  end

  def down
    drop_table :accounts
    drop_table :biz_process_control_objectives
    drop_table :biz_process_controls
    drop_table :biz_process_documents
    drop_table :biz_process_people
    drop_table :biz_processes
    drop_table :biz_process_systems
    drop_table :business_areas
    drop_table :control_control_objectives
    drop_table :control_controls
    drop_table :control_document_descriptors
    drop_table :create_control_objectives
    drop_table :controls
    drop_table :cycles
    drop_table :document_descriptors
    drop_table :documents
    drop_table :document_system_controls
    drop_table :document_systems
    drop_table :people
    drop_table :regulations
    drop_table :system_control_objectives
    drop_table :system_controls
    drop_table :system_people
    drop_table :systems
    drop_table :test_results
  end
end
