class AddBaseProgramKinds < ActiveRecord::Migration
  def up
    Option.where(:role => 'program_type').destroy_all

    role = 'program_kind'

    Option.where(:role => role, :title => 'Not Applicable').destroy_all

    [
      'Regulation', 'Company Policy', 'Operational Group Policy', 'Data Asset Policy'
    ].each do |title|
      Option.where(:role => role, :title => title).first_or_create!
    end
  end

  def down
  end
end
