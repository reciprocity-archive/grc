require 'spec_helper'
require 'base_objects'

describe CyclesHelper do
  include BaseObjects

  context "prevent duplicate titles" do    
    it "should correctly increment cycle names" do
      @program = FactoryGirl.create(:program)
      @cycle = FactoryGirl.create(:cycle, title: generate_default_title_for_cycle(@program))

      generate_default_title_for_cycle(@program).should == (@cycle.title.to_s + ' 2')
    end
  end
end
