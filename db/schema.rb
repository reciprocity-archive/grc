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

ActiveRecord::Schema.define(:version => 20130427013615) do

  create_table "accounts", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "role"
    t.string   "persistence_token"
    t.integer  "modified_by_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "person_id"
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
    t.boolean  "required"
  end

  create_table "categorizations", :force => true do |t|
    t.integer  "category_id",        :null => false
    t.integer  "categorizable_id",   :null => false
    t.string   "categorizable_type", :null => false
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "modified_by_id"
  end

  create_table "control_assessments", :force => true do |t|
    t.integer  "pbc_list_id"
    t.integer  "control_id"
    t.string   "control_version"
    t.boolean  "internal_tod"
    t.boolean  "internal_toe"
    t.boolean  "external_tod"
    t.boolean  "external_toe"
    t.text     "notes"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "control_assessments", ["control_id"], :name => "index_control_assessments_on_control_id"
  add_index "control_assessments", ["pbc_list_id"], :name => "index_control_assessments_on_pbc_list_id"

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

  create_table "control_risks", :force => true do |t|
    t.integer  "control_id",     :null => false
    t.integer  "risk_id",        :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

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
    t.string   "title",                     :null => false
    t.string   "slug",                      :null => false
    t.text     "description"
    t.integer  "directive_id"
    t.integer  "modified_by_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "parent_id"
    t.integer  "type_id"
    t.integer  "kind_id"
    t.integer  "means_id"
    t.string   "version"
    t.datetime "start_date"
    t.datetime "stop_date"
    t.string   "url"
    t.text     "documentation_description"
    t.integer  "verify_frequency_id"
    t.boolean  "fraud_related"
    t.boolean  "key_control"
    t.boolean  "active"
    t.text     "notes"
  end

  add_index "controls", ["directive_id"], :name => "index_controls_on_regulation_id"
  add_index "controls", ["slug"], :name => "index_controls_on_slug", :unique => true

  create_table "cycles", :force => true do |t|
    t.date     "start_at"
    t.boolean  "complete",       :default => false, :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "title"
    t.string   "audit_firm"
    t.string   "audit_lead"
    t.text     "description"
    t.string   "status"
    t.text     "notes"
    t.date     "end_at"
    t.integer  "program_id"
    t.date     "report_due_at"
  end

  create_table "data_assets", :force => true do |t|
    t.string   "slug"
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.integer  "modified_by_id"
    t.datetime "start_date"
    t.datetime "stop_date"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "directives", :force => true do |t|
    t.string   "title",                                 :null => false
    t.string   "slug",                                  :null => false
    t.text     "description"
    t.boolean  "company",            :default => false, :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "version"
    t.datetime "start_date"
    t.datetime "stop_date"
    t.string   "url"
    t.string   "organization"
    t.text     "scope"
    t.integer  "kind_id"
    t.datetime "audit_start_date"
    t.integer  "audit_frequency_id"
    t.integer  "audit_duration_id"
    t.string   "kind"
  end

  add_index "directives", ["slug"], :name => "index_programs_on_slug", :unique => true

  create_table "documents", :force => true do |t|
    t.string   "title"
    t.string   "link"
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.text     "description"
    t.integer  "type_id"
    t.integer  "kind_id"
    t.integer  "year_id"
    t.integer  "language_id"
  end

  create_table "facilities", :force => true do |t|
    t.string   "slug"
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.integer  "modified_by_id"
    t.datetime "start_date"
    t.datetime "stop_date"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "helps", :force => true do |t|
    t.string   "slug"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "title"
  end

  create_table "markets", :force => true do |t|
    t.string   "slug"
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.integer  "modified_by_id"
    t.datetime "start_date"
    t.datetime "stop_date"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "meetings", :force => true do |t|
    t.integer  "response_id"
    t.datetime "start_at"
    t.string   "calendar_url"
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "object_documents", :force => true do |t|
    t.string   "role"
    t.text     "notes"
    t.integer  "document_id",       :null => false
    t.integer  "documentable_id",   :null => false
    t.string   "documentable_type", :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.datetime "start_date"
    t.datetime "stop_date"
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
    t.datetime "start_date"
    t.datetime "stop_date"
  end

  add_index "object_people", ["personable_type", "personable_id"], :name => "index_object_people_on_personable_type_and_personable_id"

  create_table "options", :force => true do |t|
    t.string   "role",           :null => false
    t.string   "title",          :null => false
    t.text     "description"
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.boolean  "required"
  end

  create_table "org_groups", :force => true do |t|
    t.string   "slug"
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.integer  "modified_by_id"
    t.datetime "start_date"
    t.datetime "stop_date"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "pbc_lists", :force => true do |t|
    t.integer  "audit_cycle_id"
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "people", :force => true do |t|
    t.string   "email",          :null => false
    t.string   "name"
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "language_id"
    t.string   "company"
  end

  create_table "population_samples", :force => true do |t|
    t.integer  "response_id"
    t.integer  "population_document_id"
    t.integer  "population"
    t.integer  "sample_worksheet_document_id"
    t.integer  "samples"
    t.integer  "sample_evidence_document_id"
    t.integer  "modified_by_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "products", :force => true do |t|
    t.string   "slug"
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.string   "version"
    t.integer  "type_id"
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.datetime "start_date"
    t.datetime "stop_date"
  end

  create_table "program_directives", :force => true do |t|
    t.integer  "program_id",     :null => false
    t.integer  "directive_id",   :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "programs", :force => true do |t|
    t.string   "slug"
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.integer  "modified_by_id"
    t.datetime "start_date"
    t.datetime "stop_date"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "kind"
  end

  create_table "projects", :force => true do |t|
    t.string   "slug"
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.integer  "modified_by_id"
    t.datetime "start_date"
    t.datetime "stop_date"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "relationship_types", :id => false, :force => true do |t|
    t.string   "relationship_type"
    t.string   "description"
    t.string   "forward_phrase"
    t.string   "backward_phrase"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.boolean  "symmetric",         :default => false
  end

  add_index "relationship_types", ["relationship_type"], :name => "index_relationship_types_on_relationship_type", :unique => true

  create_table "relationships", :force => true do |t|
    t.integer  "source_id",            :null => false
    t.string   "source_type",          :null => false
    t.integer  "destination_id",       :null => false
    t.string   "destination_type",     :null => false
    t.integer  "modified_by_id"
    t.string   "relationship_type_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "relationships", ["destination_id"], :name => "index_relationships_on_destination_id"
  add_index "relationships", ["destination_type"], :name => "index_relationships_on_destination_type"
  add_index "relationships", ["relationship_type_id"], :name => "index_relationships_on_relationship_type_id"
  add_index "relationships", ["source_id"], :name => "index_relationships_on_source_id"
  add_index "relationships", ["source_type"], :name => "index_relationships_on_source_type"

  create_table "requests", :force => true do |t|
    t.integer  "pbc_list_id"
    t.integer  "type_id"
    t.string   "pbc_control_code"
    t.text     "pbc_control_desc"
    t.text     "request"
    t.text     "test"
    t.text     "notes"
    t.string   "company_responsible"
    t.string   "auditor_responsible"
    t.datetime "date_requested"
    t.string   "status"
    t.integer  "modified_by_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "control_assessment_id"
    t.date     "response_due_at"
  end

  add_index "requests", ["control_assessment_id"], :name => "index_requests_on_control_assessment_id"

  create_table "responses", :force => true do |t|
    t.integer  "request_id"
    t.integer  "system_id"
    t.string   "status"
    t.integer  "modified_by_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "risk_risky_attributes", :force => true do |t|
    t.integer  "risk_id",            :null => false
    t.integer  "risky_attribute_id", :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "risks", :force => true do |t|
    t.string   "slug"
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.integer  "modified_by_id"
    t.datetime "start_date"
    t.datetime "stop_date"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.text     "likelihood"
    t.text     "threat_vector"
    t.text     "trigger"
    t.text     "preconditions"
    t.integer  "likelihood_rating"
    t.integer  "financial_impact_rating"
    t.integer  "reputational_impact_rating"
    t.integer  "operational_impact_rating"
    t.text     "inherent_risk"
    t.text     "risk_mitigation"
    t.text     "residual_risk"
    t.text     "impact"
  end

  create_table "risky_attributes", :force => true do |t|
    t.string   "slug"
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.integer  "modified_by_id"
    t.datetime "start_date"
    t.datetime "stop_date"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "type_string"
  end

  create_table "sections", :force => true do |t|
    t.string   "title",                             :null => false
    t.string   "slug",                              :null => false
    t.text     "description"
    t.integer  "directive_id",                      :null => false
    t.integer  "modified_by_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "parent_id"
    t.boolean  "na",             :default => false, :null => false
    t.text     "notes"
    t.string   "url"
  end

  add_index "sections", ["directive_id"], :name => "index_control_objectives_on_regulation_id"
  add_index "sections", ["parent_id"], :name => "index_sections_on_parent_id"
  add_index "sections", ["slug"], :name => "index_sections_on_slug", :unique => true

  create_table "system_controls", :force => true do |t|
    t.integer  "state",          :default => 1, :null => false
    t.integer  "control_id",                    :null => false
    t.integer  "system_id",                     :null => false
    t.integer  "cycle_id"
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
    t.string   "title",                              :null => false
    t.string   "slug",                               :null => false
    t.boolean  "infrastructure",                     :null => false
    t.text     "description"
    t.integer  "owner_id"
    t.integer  "modified_by_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "is_biz_process",  :default => false
    t.integer  "type_id"
    t.datetime "start_date"
    t.datetime "stop_date"
    t.string   "url"
    t.string   "version"
    t.text     "notes"
    t.integer  "network_zone_id"
  end

  add_index "systems", ["slug"], :name => "index_systems_on_slug", :unique => true

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
