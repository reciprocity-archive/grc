class ChangeCompanyControlsToPolicy < ActiveRecord::Migration
  def up
    transaction do
      Directive.where(:kind => "Company Controls").each do |directive|
        directive.kind = "Company Controls Policy"
        directive.save!
      end
    end
  end

  def down
  end
end
