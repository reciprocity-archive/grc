require 'spec_helper'

describe Product do
  context "relationships" do
    before :each do
      @product = FactoryGirl.create(:product)
      @program = FactoryGirl.create(:program)
    end

    context "within_scope_of" do
      it "should create and find the right relationship" do
        @product.add_within_scope_of(@program)

        progs = @product.within_scope_of
        progs.count.should eq(1)
        progs.first.should eq(@program)
      end
    end

    context "Product.within_scope_of" do
      before :each do
        @product.add_within_scope_of(@program)
      end
      
      it "should return all the right products" do
        prods = Product.within_scope_of(@program)
        prods.count.should eq(1)
        prods.first.should eq(@product)
      end
    end
  end

  it 'should return the right authorizing objects' do
    @product = FactoryGirl.create(:product)
    @product.authorizing_objects.should eq(Set.new([@product]))
  end
end
