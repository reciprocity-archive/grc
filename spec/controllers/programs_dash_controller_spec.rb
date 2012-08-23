require 'spec_helper'
require 'base_objects'

describe ProgramsDashController do
  include BaseObjects

  describe "GET 'show' without authorization" do
    it "fails as guest" do
      login({}, {})
      create_base_objects
      get 'index'
      response.should be_redirect
    end
  end

  context "authorized" do
    before :each do
      login({}, { :role => 'admin' })
      create_base_objects
      @ctl2 = FactoryGirl.create(:control, :title => 'Control 2', :slug => 'REG1-CTL2', :description => 'x', :is_key => true, :fraud_related => false, :program => @creg)
      @ctl3 = FactoryGirl.create(:control, :title => 'Control 3', :slug => 'REG1-CTL2-3', :description => 'x', :is_key => true, :fraud_related => false, :program => @creg)
      @sec2 = FactoryGirl.create(:section, :title => 'Section 2', :slug => 'REG1-SEC2', :description => 'x', :program => @reg)
      @sec3 = FactoryGirl.create(:section, :title => 'Section 3', :slug => 'REG1-SEC3', :description => 'x', :program => @reg)
      @sec2.controls << @ctl
      @sec2.save
      @sec3.controls << @ctl2
      @sec3.controls << @ctl3
      @sec3.save
    end

    it "shows the programs" do
      get 'index'
      response.should be_success
      assigns(:programs).should eq([@creg, @reg])
    end
  end
end
