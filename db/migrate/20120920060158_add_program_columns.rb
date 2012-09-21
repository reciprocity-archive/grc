class AddProgramColumns < ActiveRecord::Migration
  def up
    change_table :programs do |t|
      t.string :version
      t.datetime :start_date
      t.datetime :stop_date
      t.string :url
      t.string :organization
      t.text :scope
      t.references :kind
      t.datetime :audit_start_date
      t.references :audit_frequency
      t.references :audit_duration
      t.remove :frequency
      t.remove :frequency_type
    end
  end

  def down
  end
end
