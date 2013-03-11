class AddProgramForEachDirective < ActiveRecord::Migration
  def up
    transaction do
      Directive.all.each do |directive|
        if directive.programs.count == 0
          program = Program.create!(
            :title => directive.title
          )
          program_directive = ProgramDirective.create!(
            :program => program,
            :directive => directive
          )
        end
      end
    end
  end

  def down
  end
end
