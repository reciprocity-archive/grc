require 'spec_helper'

describe Program do
  context "relationships" do
    before :each do
      @product = FactoryGirl.create(:product)
      @program = FactoryGirl.create(:program)
    end
  end

  it 'should return the right authorizing objects' do
    @program = FactoryGirl.create(:program)
    @program.authorizing_objects.should eq(Set.new([@program]))
  end
end
