require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe ControlsController do
  include BaseObjects

  before :each do
    create_base_objects
    @ctl2 = FactoryGirl.create(:control, :title => 'Control 2', :slug => 'CTL2', :description => 'x', :is_key => true, :fraud_related => false, :program => @creg)
    @ctl3 = FactoryGirl.create(:control, :title => 'Control 3', :slug => 'CTL2-CTL3', :description => 'x', :is_key => true, :fraud_related => false, :parent => @ctl2, :program => @creg)
    @sec2 = FactoryGirl.create(:section, :title => 'Section 2', :slug => 'REG1-SEC2', :description => 'x', :program => @reg)
    @sec3 = FactoryGirl.create(:section, :title => 'Section 3', :slug => 'REG1-SEC3', :description => 'x', :program => @reg)
    @sec2.controls << @ctl
    @sec2.save
    @sec3.controls << @ctl2
    @sec3.controls << @ctl3
    @sec3.save

    # Authorized_controller test setup
    @model = Control
    @index_objs = [@ctl, @ctl2, @ctl3]
    @show_obj = @ctl
  end

  it_behaves_like "an authorized controller"

  context "authorized" do
    before :each do
      login({}, { :role => 'admin' })
    end

    it "edits" do
      get 'edit', :id => @ctl.id
      response.should be_success
      assigns(:control).should eq(@ctl)
    end

    it "updates" do
      put 'update', :id => @ctl.id
      response.should be_redirect
    end

    it "news" do
      get 'new'
      response.should be_success
      assigns(:control).class.should eq(Control)
    end

    it "creates" do
      post 'create', :control => { :slug => 'test', :title => 'test', :program_id => @creg.id }
      response.should be_redirect
    end
  end
end
