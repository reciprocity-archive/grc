require 'spec_helper'

describe SluggedModel do
  before :each do
    @ap1 = FactoryGirl.create(:directive, :slug => 'FASLUG1')
    @ap2 = FactoryGirl.create(:directive, :slug => 'FASLUG2')
    @bp1 = FactoryGirl.create(:directive, :slug => 'FBSLUG1')
    @bp2 = FactoryGirl.create(:directive, :slug => 'FBSLUG2')
    @as1 = FactoryGirl.create(:section, :slug => 'FASLUG1-ASEC1', :directive => @ap1)
    @as2 = FactoryGirl.create(:section, :slug => 'FASLUG1-ASEC2', :directive => @ap1)
    @bs1 = FactoryGirl.create(:section, :slug => 'FBSLUG1-ASEC1', :directive => @bp1)
    @bs2 = FactoryGirl.create(:section, :slug => 'FBSLUG1-ASEC2', :directive => @bp1)
  end

  context "compact_slug" do
    it "should return the slug minus the parent prefix" do
      parent = FactoryGirl.create(:section, :slug => 'PARENT')
      child = FactoryGirl.create(:section, :slug => 'PARENT-CHILD', :parent => parent)
      child.compact_slug.should eq('-CHILD')
    end
  end

  context "validate_slug" do
    it "should throw an error on a duplicate slug ID" do
      @c1 = FactoryGirl.create(:control, :slug => 'DUPESLUG')
      lambda { @c2 = FactoryGirl.create(:control, :slug => 'DUPESLUG', :parent => @c1) }.should raise_error
    end
  end

  context "generate" do
    it "should generate an ID when one isn't given" do
      p = Directive.create(:title => 'Test Directive')
      p.slug.should eq('DIRECTIVE-%04d' % p.id)
    end

    it "should generate a slug with the correct name when there is a parent" do
      p = FactoryGirl.create(:directive)
      s = Section.create({:title => 'parent', :directive => p}, :without_protection => true)
      s2 = Section.create({:title => 'child', :parent => s, :directive => p}, :without_protection => true)

      s2.slug.should eq(s.slug + '-SECTION-%04d' % s2.id)
    end

    it "should undo the generated slug in the case of a validation failure" do
      p = Directive.new
      p.save
      p.slug.should eq(nil)
    end
  end

  context "SlugTree" do
    context "initialize" do
      it "should initialize properly" do
        st = Directive.slugtree([@bs1, @bs2])
        st.prefix.should eq('')
        st.parent.should eq(nil)
      end
    end

    context "insert" do
      it "should not allow inserting invalid children" do
        st = SluggedModel::SlugTree.new('ASLUG')
        lambda { st.insert(@bs1) }.should raise_error
      end
    end
  end

  context "ClassMethods" do
    context "slugfilter" do
      it "should properly filter" do
        r = Directive.slugfilter('FA')
        r.count.should eq(2)
        r.all.should eq([@ap1, @ap2])
        r = Directive.slugfilter('FB')
        r.count.should eq(2)
        r.all.should eq([@bp1, @bp2])
        r = Directive.slugfilter('F')

        r.count.should eq(4)
        r.all.should eq([@ap1, @ap2, @bp1, @bp2])
      end
    end

    context "slugtree" do
      it "should have properly sorted and hierarchical children" do
        st = Directive.slugtree(Control.all)
      end
    end
  end
end
