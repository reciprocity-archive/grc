require 'spec_helper'

describe Document do
  
  it "should correctly count population samples" do
    @document = FactoryGirl.create(:document)
    @document.population_worksheets_documented << FactoryGirl.create(:population_sample)
    @document.count_population_samples.should == 1
    @document.sample_worksheets_documented << FactoryGirl.create(:population_sample)
    @document.count_population_samples.should == 2
    @document.sample_evidences_documented << FactoryGirl.create(:population_sample)
    @document.count_population_samples.should == 3
  end  
end
