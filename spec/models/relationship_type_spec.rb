require 'spec_helper'

describe RelationshipType do
  before :each do
    @maker_of = FactoryGirl.create(:relationship_type, :relationship_type => 'maker_of',
                              :description => 'The source is the maker of the destination',
                              :forward_phrase => 'is the maker of',
                              :backward_phrase => 'is made by')
  end

  it 'find should work with string primary key' do
    RelationshipType.find('maker_of').should eq(@maker_of)
  end

  context 'search' do
    before :each do
      @source = FactoryGirl.create(:directive)
      @dest = FactoryGirl.create(:directive)
      @rel = FactoryGirl.create(:relationship, :source => @source, :destination => @dest, :relationship_type_id => 'maker_of')
    end

    it 'should be able to find all relationships with the relationship type' do
      rels = @maker_of.relationships
      rels.count.should eq(1)
    end
  end
end
