require 'spec_helper'

describe Program do
  context "relationships" do
    before :each do
      @product = FactoryGirl.create(:product)
      @program = FactoryGirl.create(:program)
    end

    context "relevant_to" do
      it "should create and find the right relationship" do
        @program.add_relevant_to(@product)

        prods = @program.relevant_to
        prods.count.should eq(1)
        prods.first.should eq(@product)
      end
    end

    context "Program.relevant_to" do
      before :each do
        @program.add_relevant_to(@product)
      end
      
      it "should return all the right products" do
        progs = Program.relevant_to(@product)
        progs.count.should eq(1)
        progs.first.should eq(@program)
      end
    end
  end

  it 'should return the right authorizing objects' do
    @program = FactoryGirl.create(:program)
    @program.authorizing_objects.should eq(Set.new([@program]))
  end
end
