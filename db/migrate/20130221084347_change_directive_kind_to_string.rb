class ChangeDirectiveKindToString < ActiveRecord::Migration
  def up
    transaction do
      Directive.all.each do |directive|
        option = Option.where(:role => 'directive_kind', :id => directive.kind_id).first
        kind = option ? option.title : "Regulation"
        kind = "Org Group Policy" if kind == "Operational Group Policy"
        directive.update_attribute(:kind, kind)
      end
    end
  end

  def down
  end
end
