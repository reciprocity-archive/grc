class AddCompanyControlsProgram < ActiveRecord::Migration
  def up
    transaction do
      p = Program.where(:kind => "Company Controls").first
      if p.nil?
        p = Program.create(:kind => "Company Controls", :title => "Company Controls")
      end

      Directive.where(:kind => "Company Controls").each do |d|
        pd = ProgramDirective.where(:program_id => p.id, :directive_id => d.id).first
        if pd.nil?
          pd = ProgramDirective.new
          pd.program = p
          pd.directive = d
          pd.save!
        end
      end

      Program.where(:kind => nil).each do |p|
        p.kind = "Directive"
        p.save!
      end
    end
  end

  def down
  end
end
