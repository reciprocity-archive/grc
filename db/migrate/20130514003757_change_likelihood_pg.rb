class ChangeLikelihoodPg < ActiveRecord::Migration
  def _is_postgresql?
    begin
      ActiveRecord::Base.connection.kind_of?(
        ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
    rescue
      false
    end
  end

  def up
    if _is_postgresql?
        connection.execute(%q{
            alter table risks
            alter column likelihood_rating type float using cast(likelihood_rating as float),
            alter column likelihood_rating set default 0.2
        })
    else
        change_column :risks, :likelihood_rating, :float
    end
  end

  def down
    if _is_postgresql?
        connection.execute(%q{
            alter table risks
            alter column likelihood_rating type integer using cast(likelihood_rating as integer),
            alter column likelihood_rating set default 1
        })
    else
        change_column :risks, :likelihood_rating, :integer
    end
  end
end
