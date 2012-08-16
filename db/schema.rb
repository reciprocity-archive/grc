# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120816195416) do

  create_table "accounts", :force => true do |t|
    t.string   "username"
    t.string   "name"
    t.string   "surname"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "role"
    t.string   "persistence_token"
    t.integer  "modified_by_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "biz_process_controls", :force => true do |t|
    t.integer  "state",          :default => 1, :null => false
    t.string   "ticket"
    t.integer  "biz_process_id",                :null => false
    t.integer  "control_id",                    :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "biz_process_controls", ["biz_process_id"], :name => "index_biz_process_controls_on_biz_process_id"
  add_index "biz_process_controls", ["control_id"], :name => "index_biz_process_controls_on_control_id"

  create_table "biz_process_documents", :force => true do |t|
    t.integer  "biz_process_id", :null => false
    t.integer  "policy_id",      :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "biz_process_documents", ["biz_process_id", "policy_id"], :name => "index_biz_process_documents_on_biz_process_id_and_policy_id", :unique => true
  add_index "biz_process_documents", ["biz_process_id"], :name => "index_biz_process_documents_on_biz_process_id"
  add_index "biz_process_documents", ["policy_id"], :name => "index_biz_process_documents_on_policy_id"

  create_table "biz_process_people", :force => true do |t|
    t.integer  "role",           :default => 1, :null => false
    t.integer  "person_id",                     :null => false
    t.integer  "biz_process_id",                :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "biz_process_people", ["biz_process_id"], :name => "index_biz_process_people_on_biz_process_id"
  add_index "biz_process_people", ["person_id"], :name => "index_biz_process_people_on_person_id"

  create_table "biz_process_sections", :force => true do |t|
    t.integer  "biz_process_id", :null => false
    t.integer  "section_id",     :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "biz_process_sections", ["biz_process_id", "section_id"], :name => "index_biz_process_control_objectives_uniqueness", :unique => true
  add_index "biz_process_sections", ["section_id"], :name => "index_biz_process_sections_on_section_id"

  create_table "biz_process_systems", :force => true do |t|
    t.integer  "biz_process_id", :null => false
    t.integer  "system_id",      :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "biz_process_systems", ["biz_process_id", "system_id"], :name => "index_biz_process_systems_uniqueness", :unique => true
  add_index "biz_process_systems", ["biz_process_id"], :name => "index_biz_process_systems_on_biz_process_id"
  add_index "biz_process_systems", ["system_id"], :name => "index_biz_process_systems_on_system_id"

  create_table "biz_processes", :force => true do |t|
    t.string   "title",          :null => false
    t.string   "slug",           :null => false
    t.text     "description"
    t.integer  "owner_id"
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "biz_processes", ["owner_id"], :name => "index_biz_processes_on_owner_id"
  add_index "biz_processes", ["slug"], :name => "index_biz_processes_on_slug", :unique => true

  create_table "business_areas", :force => true do |t|
    t.string   "title"
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "scope_id"
    t.integer  "depth"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "modified_by_id"
  end

  create_table "categorizations", :force => true do |t|
    t.integer  "category_id",        :null => false
    t.integer  "categorizable_id",   :null => false
    t.string   "categorizable_type", :null => false
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "modified_by_id"
  end

  create_table "control_controls", :force => true do |t|
    t.integer  "control_id",             :null => false
    t.integer  "implemented_control_id", :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  add_index "control_controls", ["control_id", "implemented_control_id"], :name => "index_control_controls_uniqueness", :unique => true
  add_index "control_controls", ["control_id"], :name => "index_control_controls_on_control_id"
  add_index "control_controls", ["implemented_control_id"], :name => "index_control_controls_on_implemented_control_id"

  create_table "control_document_descriptors", :force => true do |t|
    t.integer  "control_id",             :null => false
    t.integer  "evidence_descriptor_id", :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  add_index "control_document_descriptors", ["control_id", "evidence_descriptor_id"], :name => "index_control_document_descriptors_uniqueness", :unique => true
  add_index "control_document_descriptors", ["control_id"], :name => "index_control_document_descriptors_on_control_id"
  add_index "control_document_descriptors", ["evidence_descriptor_id"], :name => "index_control_document_descriptors_on_evidence_descriptor_id"

  create_table "control_sections", :force => true do |t|
    t.integer  "control_id",     :null => false
    t.integer  "section_id",     :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "control_sections", ["control_id", "section_id"], :name => "index_control_control_objectives_uniqueness", :unique => true
  add_index "control_sections", ["control_id"], :name => "index_control_control_objectives_on_control_id"
  add_index "control_sections", ["section_id"], :name => "index_control_control_objectives_on_control_objective_id"

  create_table "controls", :force => true do |t|
    t.string   "title",                               :null => false
    t.string   "slug",                                :null => false
    t.boolean  "is_key",           :default => false, :null => false
    t.text     "description"
    t.integer  "frequency"
    t.integer  "frequency_type",   :default => 1
    t.boolean  "fraud_related",    :default => false, :null => false
    t.boolean  "technical",        :default => true,  :null => false
    t.string   "assertion"
    t.datetime "effective_at"
    t.integer  "business_area_id"
    t.integer  "program_id"
    t.integer  "test_result_id"
    t.integer  "modified_by_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "parent_id"
    t.integer  "type_id"
    t.integer  "kind_id"
    t.integer  "means_id"
  end

  add_index "controls", ["business_area_id"], :name => "index_controls_on_business_area_id"
  add_index "controls", ["program_id"], :name => "index_controls_on_regulation_id"
  add_index "controls", ["slug"], :name => "index_controls_on_slug", :unique => true
  add_index "controls", ["test_result_id"], :name => "index_controls_on_test_result_id"

  create_table "cycles", :force => true do |t|
    t.integer  "program_id",                        :null => false
    t.date     "start_at"
    t.boolean  "complete",       :default => false, :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "cycles", ["program_id"], :name => "index_cycles_on_regulation_id"

  create_table "document_descriptors", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "document_system_controls", :force => true do |t|
    t.integer  "evidence_id",       :null => false
    t.integer  "system_control_id", :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "document_system_controls", ["evidence_id", "system_control_id"], :name => "index_document_system_controls_uniqueness", :unique => true
  add_index "document_system_controls", ["evidence_id"], :name => "index_document_system_controls_on_evidence_id"
  add_index "document_system_controls", ["system_control_id"], :name => "index_document_system_controls_on_system_control_id"

  create_table "document_systems", :force => true do |t|
    t.integer  "document_id",    :null => false
    t.integer  "system_id",      :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "document_systems", ["document_id", "system_id"], :name => "index_document_systems_uniqueness", :unique => true
  add_index "document_systems", ["document_id"], :name => "index_document_systems_on_document_id"
  add_index "document_systems", ["system_id"], :name => "index_document_systems_on_system_id"

  create_table "documents", :force => true do |t|
    t.string   "title"
    t.string   "link"
    t.integer  "document_descriptor_id"
    t.boolean  "reviewed",               :default => false, :null => false
    t.boolean  "good",                   :default => true
    t.integer  "modified_by_id"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "documents", ["document_descriptor_id"], :name => "index_documents_on_document_descriptor_id"

  create_table "object_documents", :force => true do |t|
    t.string   "role"
    t.text     "notes"
    t.integer  "document_id",       :null => false
    t.integer  "documentable_id",   :null => false
    t.string   "documentable_type", :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "object_documents", ["documentable_type", "documentable_id"], :name => "index_object_documents_on_documentable_type_and_documentable_id"

  create_table "object_people", :force => true do |t|
    t.string   "role"
    t.text     "notes"
    t.integer  "person_id",       :null => false
    t.integer  "personable_id",   :null => false
    t.string   "personable_type", :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "object_people", ["personable_type", "personable_id"], :name => "index_object_people_on_personable_type_and_personable_id"

  create_table "options", :force => true do |t|
    t.string   "role",           :null => false
    t.string   "title",          :null => false
    t.text     "description"
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "people", :force => true do |t|
    t.string   "username",       :null => false
    t.string   "name"
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "language_id"
    t.string   "company"
  end

  create_table "programs", :force => true do |t|
    t.string   "title",                                 :null => false
    t.string   "slug",                                  :null => false
    t.text     "description"
    t.boolean  "company",            :default => false, :null => false
    t.integer  "source_document_id"
    t.integer  "source_website_id"
    t.integer  "modified_by_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "frequency_type",     :default => 1
    t.integer  "frequency",          :default => 1
  end

  add_index "programs", ["slug"], :name => "index_programs_on_slug", :unique => true
  add_index "programs", ["source_document_id"], :name => "index_regulations_on_source_document_id"
  add_index "programs", ["source_website_id"], :name => "index_regulations_on_source_website_id"

  create_table "sections", :force => true do |t|
    t.string   "title",                             :null => false
    t.string   "slug",                              :null => false
    t.text     "description"
    t.integer  "program_id",                        :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "parent_id"
    t.boolean  "na",             :default => false, :null => false
    t.text     "notes"
  end

  add_index "sections", ["parent_id"], :name => "index_sections_on_parent_id"
  add_index "sections", ["program_id"], :name => "index_control_objectives_on_regulation_id"
  add_index "sections", ["slug"], :name => "index_sections_on_slug", :unique => true

  create_table "system_controls", :force => true do |t|
    t.integer  "state",               :default => 1, :null => false
    t.string   "ticket"
    t.integer  "control_id",                         :null => false
    t.integer  "system_id",                          :null => false
    t.integer  "cycle_id"
    t.text     "test_why"
    t.text     "test_impact"
    t.text     "test_recommendation"
    t.integer  "modified_by_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "system_people", :force => true do |t|
    t.integer  "role",           :default => 1, :null => false
    t.integer  "person_id",                     :null => false
    t.integer  "system_id",                     :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "system_sections", :force => true do |t|
    t.integer  "state",          :default => 1, :null => false
    t.integer  "section_id",                    :null => false
    t.integer  "system_id",                     :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "system_systems", :force => true do |t|
    t.integer  "parent_id",      :null => false
    t.integer  "child_id",       :null => false
    t.string   "type"
    t.integer  "order"
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "systems", :force => true do |t|
    t.string   "title",                             :null => false
    t.string   "slug",                              :null => false
    t.boolean  "infrastructure",                    :null => false
    t.text     "description"
    t.integer  "owner_id"
    t.integer  "modified_by_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "is_biz_process", :default => false
    t.integer  "type_id"
  end

  add_index "systems", ["slug"], :name => "index_systems_on_slug", :unique => true

  create_table "test_results", :force => true do |t|
    t.string   "title",                             :null => false
    t.boolean  "passed",         :default => false, :null => false
    t.text     "output"
    t.integer  "modified_by_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "transactions", :force => true do |t|
    t.string   "title",          :null => false
    t.text     "description"
    t.integer  "system_id"
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
