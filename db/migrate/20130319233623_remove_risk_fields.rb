class RemoveRiskFields < ActiveRecord::Migration
  def up
    remove_column :risks, :financial_impact
    remove_column :risks, :reputational_impact
    remove_column :risks, :operational_impact
  end

  def down
  end
end
