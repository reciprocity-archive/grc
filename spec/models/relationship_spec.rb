require 'spec_helper'

describe Relationship do
  before :each do
    @program = FactoryGirl.create(:program)
    @product = FactoryGirl.create(:product)
    @maker_of = FactoryGirl.create(:relationship_type, :relationship_type => 'maker_of',
                              :description => 'The source is the maker of the destination',
                              :forward_short_description => 'is the maker of',
                              :backward_short_description => 'is made by')
    @rel = FactoryGirl.create(:relationship, :source => @program, :destination => @product, :relationship_type => @maker_of)
  end

  context 'create relationships between two different types of objects' do
    it 'should require source, destination, and relationship_type_id'
  end

  context 'associations ' do
    it 'should have a relationship_type' do
      rel = FactoryGirl.create(:relationship, :source => @program, :destination => @product, :relationship_type => @maker_of)
      rel.relationship_type.should eq(@maker_of)
    end
  end

  context 'creation' do
    it 'should create a new relationship' do
      rel = FactoryGirl.create(:relationship, :source => @program, :destination => @product, :relationship_type_id => 'is_related_to')
      rel.source.should eq(@program)
      rel.destination.should eq(@product)
    end
  end
end
