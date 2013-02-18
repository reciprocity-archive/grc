require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe ControlsController do
  include BaseObjects

  context "CRUD" do
    before :each do
      create_base_objects

      @ctl2 = FactoryGirl.create(:control, :title => 'Control 2', :slug => 'CTL2', :description => 'x', :directive => @creg)
      @ctl3 = FactoryGirl.create(:control, :title => 'Control 3', :slug => 'CTL2-CTL3', :description => 'x', :parent => @ctl2, :directive => @creg)
      @sec2 = FactoryGirl.create(:section, :title => 'Section 2', :slug => 'REG1-SEC2', :description => 'x', :directive => @reg)
      @sec3 = FactoryGirl.create(:section, :title => 'Section 3', :slug => 'REG1-SEC3', :description => 'x', :directive => @reg)
      @sec2.controls << @ctl
      @sec2.save
      @sec3.controls << @ctl2
      @sec3.controls << @ctl3
      @sec3.save

      # Authorized_controller test setup
      @model = Control
      @index_objs = [@ctl, @ctl2, @ctl3]
      @object = @ctl
      @create_params = { :slug => 'test', :title => 'test', :directive_id => @creg.id }
    end

    it_behaves_like "an authorized create"
    it_behaves_like "an authorized new"
    it_behaves_like "an authorized index"
    it_behaves_like "an authorized edit"
    it_behaves_like "an authorized delete"
    it_behaves_like "an authorized update", ['update']
    it_behaves_like "an authorized read", ['show',
                                           'tooltip',
                                           'sections',
                                           'implemented_controls',
                                           'implementing_controls']
  end

  context "related" do
    before :each do
      login({}, {:role => 'superuser'})
      create_base_objects

      @ctl2 = FactoryGirl.create(:control, :title => 'Control 2', :slug => 'CTL2', :description => 'x', :directive => @creg)
      @ctl3 = FactoryGirl.create(:control, :title => 'Control 3', :slug => 'CTL2-CTL3', :description => 'x', :parent => @ctl2, :directive => @creg)
      @sec2 = FactoryGirl.create(:section, :title => 'Section 2', :slug => 'REG1-SEC2', :description => 'x', :directive => @reg)
      @sec3 = FactoryGirl.create(:section, :title => 'Section 3', :slug => 'REG1-SEC3', :description => 'x', :directive => @reg)
      @sec2.controls << @ctl
      @sec2.save
      @sec3.controls << @ctl2
      @sec3.controls << @ctl3
      @sec3.save

      @object = @ctl
    end

    # FIXME: I don't know what these should actually do. They
    # should really be refactored, anyway, since they're not actually
    # returning controls.
    context "sections" do
      it "returns the right sections" do
        get 'sections', :id => @ctl.id
        assigns(:sections).should eq([@sec2])
      end
    end
    
    context "implemented_controls" do
      it "returns the right implemented controls" do
        get 'implemented_controls', :id => @ctl.id
        assigns(:controls).should eq([])
      end
    end

    context "implementing_controls" do
      it "returns the right implementing controls" do
        get 'implemented_controls', :id => @ctl.id
        assigns(:controls).should eq([])
      end
    end
  end
end
