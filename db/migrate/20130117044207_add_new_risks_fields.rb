class AddNewRisksFields < ActiveRecord::Migration
  def change
    change_table :risks do |t|
      t.text :likelihood
      t.text :threat_vector
      t.text :trigger
      t.text :preconditions

      t.text :financial_impact
      t.text :reputational_impact
      t.text :operational_impact

      t.integer :likelihood_rating
      t.integer :financial_impact_rating
      t.integer :reputational_impact_rating
      t.integer :operational_impact_rating
    end
  end
end
