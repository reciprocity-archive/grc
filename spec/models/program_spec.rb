require 'spec_helper'

describe Program do
  before :each do
    @program = FactoryGirl.create(:program)
  end
  it 'should return the right authorizing objects' do
    @program.authorizing_objects.should eq(Set.new([@program]))
  end
end
