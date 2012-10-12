require 'spec_helper'

describe Product do
  it 'should return the right authorizing objects' do
    @product = FactoryGirl.create(:product)
    @product.authorizing_objects.should eq(Set.new([@product]))
  end
end
