require 'spec_helper'

describe SlugfilterHelper do

  # See http://injecting.by2.be/blog/2010/06/rails3_rspec2_haml.html
  # needed for using HAML helpers
  include Haml::Helpers
  include ActionView::Helpers

  before :each do
    init_haml_helpers
    @ap1 = FactoryGirl.create(:directive, :slug => 'ASLUG1')
    @ap2 = FactoryGirl.create(:directive, :slug => 'ASLUG2')
    @bp1 = FactoryGirl.create(:directive, :slug => 'BSLUG1')
    @bp2 = FactoryGirl.create(:directive, :slug => 'BSLUG2')
    @as1 = FactoryGirl.create(:section, :slug => 'ASLUG1-ASEC1', :directive => @ap1)
    @as2 = FactoryGirl.create(:section, :slug => 'ASLUG1-ASEC2', :directive => @ap1)
    @bs1 = FactoryGirl.create(:section, :slug => 'BSLUG1-ASEC1', :directive => @bp1)
    @bs2 = FactoryGirl.create(:section, :slug => 'BSLUG1-ASEC2', :directive => @bp1)
  end

  context "walk_slug_tree" do
    it "should properly insert resulting blocks"
    it "should properly generate a slugtree" do
      result = walk_slug_tree(Directive.slugtree([@ap1, @as1, @as2])) do |object, step|

      end
      result.should have_selector('li#content_ASLUG1')
      result.should have_selector('li#content_ASLUG1 ul#children_ASLUG1')
      result.should have_selector('li#content_ASLUG1 ul#children_ASLUG1 li#content_ASLUG1-ASEC1')
    end

    it "should properly generate a slugtree given depth" do
      result = walk_slug_tree(Directive.slugtree([@ap1, @as1, @as2]), :depth => 1) do |object, step|

      end
      result.should have_selector('li#content_ASLUG1')
      result.should_not have_selector('li#content_ASLUG1 ul#children_ASLUG1')
      result.should_not have_selector('li#content_ASLUG1 ul#children_ASLUG1 li#content_ASLUG1-ASEC1')
    end
  end
end
