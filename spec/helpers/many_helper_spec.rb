require 'spec_helper'

describe ManyHelper do
  before :each do
    @reg = FactoryGirl.create(:directive, :title => 'Reg 1', :slug => 'reg1', :company => true)
    @ctl1 = FactoryGirl.create(:control, :title => 'Control 1', :slug => 'reg1-ctl1', :description => 'x', :directive => @reg)
    @ctl2 = FactoryGirl.create(:control, :title => 'Control 2', :slug => 'reg1-ctl2', :description => 'x', :directive => @reg)
    @sys = FactoryGirl.create(:system, :title => 'System 1', :slug => 'sys1', :description => 'x', :infrastructure => true)
    @sc = FactoryGirl.create(:system_control, :control => @ctl2, :system => @sys, :state => :green)
    helper.set_rspec(self)
    #helper.instance_variable_set(:@_rspec, self)
  end

  describe "get many2many" do
    it "gets it" do
      helper.get_many2many(:left_class => Control, :right_class => System)
      helper.instance_variable_get(:@lefts).should == [@ctl1, @ctl2] # TODO should ctl3 be excluded?
      helper.instance_variable_get(:@left).should == @ctl1
      helper.instance_variable_get(:@rights).should == [@sys]
    end
  end

  describe "put many2many" do
    it "inserts" do
      params[:id] = @ctl1.id
      params[:control] = {}
      params[:control]["system_ids"] = [ @sys.id ]
      helper.should_receive(:redirect_to).with(:id => @ctl1.id)
      helper.post_many2many(:left_class => Control, :right_class => System)
      @sys.controls.all(:order => :slug).should eq([@ctl1, @ctl2])
    end
    it "deletes" do
      params[:id] = @ctl2.id
      params[:control] = {}
      params[:control]["system_ids"] = []
      helper.should_receive(:redirect_to).with(:id => @ctl2.id)
      helper.post_many2many(:left_class => Control, :right_class => System)
      @sys.controls.all(:order => :slug).should eq([])
    end
  end
end
