class FixResponsesWithoutPopSamples2 < ActiveRecord::Migration
  def up
    transaction do
      Response
       .joins( :request )
       .where( :requests => { :type_id => 2 } )
       .joins("left outer join population_samples as population_sample on population_sample.response_id = responses.id")
       .where(:population_sample => { :id => nil })
       .each { |resp| PopulationSample.new({ :response => resp }).save! }
    end
  end

  def down
  end
end
