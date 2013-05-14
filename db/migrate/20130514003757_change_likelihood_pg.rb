class ChangeLikelihoodPg < ActiveRecord::Migration
  def up
    case ActiveRecord::Base.connection
    when ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        connection.execute(%q{
            alter table risks
            alter column likelihood_rating type float using cast(likelihood_rating as float),
            alter column likelihood_rating set default 0.2
        })
    when ActiveRecord::ConnectionAdapters::SQLite3
        change_column :risks, :likelihood_rating, :float
    end
  end

  def down
    case ActiveRecord::Base.connection
    when ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        connection.execute(%q{
            alter table risks
            alter column likelihood_rating type integer using cast(likelihood_rating as integer),
            alter column likelihood_rating set default 1
        })
    when ActiveRecord::ConnectionAdapters::SQLite3
        change_column :risks, :likelihood_rating, :integer
    end
  end
end
