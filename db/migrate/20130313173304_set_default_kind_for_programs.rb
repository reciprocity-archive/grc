class SetDefaultKindForPrograms < ActiveRecord::Migration
  def up
    transaction do
      Program.all.each do |program|
        program.kind = "Directive" if program.kind.blank?
        program.save!
      end
    end
  end

  def down
  end
end
