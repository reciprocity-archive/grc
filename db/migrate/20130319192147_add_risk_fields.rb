class AddRiskFields < ActiveRecord::Migration
  def change
    add_column :risks, :inherent_risk, :text
    add_column :risks, :risk_mitigation, :text
    add_column :risks, :residual_risk, :text

    add_column :risks, :impact, :text
  end
end
