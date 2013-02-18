require 'spec_helper'

describe RelatedModel do
  context 'scope helpers' do
    before :each do
      @directive = FactoryGirl.create(:directive)
      @product = FactoryGirl.create(:product)
      @maker_of = FactoryGirl.create(:relationship_type, :relationship_type => 'maker_of',
                                :description => 'The source is the maker of the destination',
                                :forward_phrase => 'is the maker of',
                                :backward_phrase => 'is made by')
      @rel = FactoryGirl.create(:relationship, :source => @directive, :destination => @product, :relationship_type_id => 'maker_of')
      @rel2 = FactoryGirl.create(:relationship, :source => @directive, :destination => @product, :relationship_type_id => 'within_scope_of')
    end
    
    context 'related_to_source' do
      it 'should only find the related destination' do
        prods = Product.related_to_source(@directive, 'maker_of')
        prods.count.should eq(1)
        prods[0].should eq(@product)
      end
    end

    context 'related_to_destination' do
      it 'should only find the related source' do
        progs = Directive.related_to_destination('maker_of', @product)
        progs.count.should eq(1)
        progs[0].should eq(@directive)
      end
    end
  end
end
