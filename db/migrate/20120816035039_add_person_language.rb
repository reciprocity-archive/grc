class AddPersonLanguage < ActiveRecord::Migration
  # Add a 'language_id' association from Person to the Option table

  # Local models so that migration is safe
  class Option < ActiveRecord::Base
    attr_accessible :role, :title
  end

  def up
    add_column :people, :language_id, :integer

    Option.reset_column_information

    Option.create(:role => 'person_language', :title => 'English')
  end

  def down
    remove_column :people, :language_id
  end
end
