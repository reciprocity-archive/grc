class ChangeLikelihoodAttribute < ActiveRecord::Migration
  def up
    change_table :risks do |t|
      t.change :likelihood_rating, :float
    end
  end

  def down
  end
end
