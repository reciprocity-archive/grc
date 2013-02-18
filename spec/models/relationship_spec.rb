require 'spec_helper'

include ApplicationHelper

describe Relationship do
  before :each do
    @directive = FactoryGirl.create(:directive)
    @product = FactoryGirl.create(:product)
    @maker_of = FactoryGirl.create(:relationship_type, :relationship_type => 'maker_of',
                              :description => 'The source is the maker of the destination',
                              :forward_phrase => 'is the maker of',
                              :backward_phrase => 'is made by')
    @rel = FactoryGirl.create(:relationship, :source => @directive, :destination => @product, :relationship_type => @maker_of)
  end

  context 'create relationships between two different types of objects' do
    it 'should require source, destination, and relationship_type_id'
  end

  context 'associations ' do
    it 'should have a relationship_type' do
      rel = FactoryGirl.create(:relationship, :source => @directive, :destination => @product, :relationship_type => @maker_of)
      rel.relationship_type.should eq(@maker_of)
    end
  end

  context 'creation' do
    it 'should create a new relationship' do
      rel = FactoryGirl.create(:relationship, :source => @directive, :destination => @product, :relationship_type_id => 'is_related_to')
      rel.source.should eq(@directive)
      rel.destination.should eq(@product)
    end
  end

  context 'validation' do
    it 'should not use an invalid relationship type' do
      types = DefaultRelationshipTypes.types.keys
      all_models do |m|
        if m.respond_to?(:valid_relationships)
          m.valid_relationships.each do |r|
            types.should include(r[:relationship_type].to_s)
          end
        end
      end
    end
  end
end
