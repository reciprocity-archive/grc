class SetProgramIdOnCycles < ActiveRecord::Migration
  def up
    transaction do
      Cycle.all.each do |cycle|
        directive = Directive.find(cycle.directive_id)
        program = directive.programs.first
        cycle.update_attribute(:program_id, program.id)
      end
    end
  end

  def down
  end
end
