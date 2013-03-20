class ConsolidateRiskFields < ActiveRecord::Migration
  def up
    transaction do
      Risk.all.each do |risk|
        impact = [risk.financial_impact, risk.reputational_impact, risk.operational_impact]
        impact = impact.map(&:presence).compact.join("<br />")
        risk.update_attribute(:impact, impact)
      end
    end
  end

  def down
  end
end
