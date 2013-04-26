class FixResponsesWithoutPopSamples < ActiveRecord::Migration
  def up
    Response
     .joins( :request )
     .where( :requests => { :type_id => 2 } )
     .joins("left outer join population_samples as population_sample on population_sample.response_id = responses.id")
     .where(:population_sample => { :id => 1 })
     .each {|resp| PopulationSample.new({ :response => resp }).save }
  end

  def down
  end
end
