class AddControlColumns < ActiveRecord::Migration
  def up
    change_table :controls do |t|
      t.string :version
      t.datetime :start_date
      t.datetime :stop_date
      t.string :url
      t.text :documentation_description
      t.references :verify_frequency
      t.remove :frequency
      t.remove :frequency_type
      t.remove :effective_at
    end
  end

  def down
  end
end
