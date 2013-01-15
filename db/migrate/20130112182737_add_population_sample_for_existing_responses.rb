class AddPopulationSampleForExistingResponses < ActiveRecord::Migration
  def up
    Request.all.
      select { |r| r.type_name == 'Population Sample' }.
      map { |r| r.responses.all }.
      flatten.
      each { |r| r.create_population_sample if r.population_sample.nil? }
  end

  def down
  end
end
