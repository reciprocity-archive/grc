class CreateMeetings < ActiveRecord::Migration
  def change
    create_table :meetings do |t|
      t.references :response
      t.datetime :start_at
      t.string :calendar_url

      t.references :modified_by
      t.timestamps
    end
  end
end
