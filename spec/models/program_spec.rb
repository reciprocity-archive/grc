require 'spec_helper'

describe Program do
  context "relationships" do
    before :each do
      @product = FactoryGirl.create(:product)
      @program = FactoryGirl.create(:program)
    end
  end
end
