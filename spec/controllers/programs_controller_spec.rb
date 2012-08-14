require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe ProgramsController do
  include BaseObjects

  before :each do
    create_base_objects

    # For use by authorized_controller tests
    @model = Program
    @show_obj = @reg
    @login_role = 'admin'
  end

  it_behaves_like "an authorized controller"

  context "authorized" do
    before :each do
      login({}, { :role => 'admin' })
      @ctl2 = FactoryGirl.create(:control, :title => 'Control 2', :slug => 'CTL2', :description => 'x', :is_key => true, :fraud_related => false, :program => @creg)
      @ctl3 = FactoryGirl.create(:control, :title => 'Control 3', :slug => 'CTL2-1', :description => 'x', :is_key => true, :fraud_related => false, :parent => @ctl2, :program => @creg)
      @sec2 = FactoryGirl.create(:section, :title => 'Section 2', :slug => 'REG1-SEC2', :description => 'x', :program => @reg)
      @sec3 = FactoryGirl.create(:section, :title => 'Section 3', :slug => 'REG1-SEC3', :description => 'x', :program => @reg)
      @sec2.controls << @ctl
      @sec2.save
      @sec3.controls << @ctl2
      @sec3.controls << @ctl3
      @sec3.save
    end

    it "shows stats" do
      get 'show', :id => @reg.id
      stats = assigns(:stats)
      stats[:sections_count].should eq(3)
      stats[:sections_done_count].should eq(2)
      stats[:sections_undone_count].should eq(1)
      stats[:sections_na_count].should eq(0)
      stats[:controls_count].should eq(3)
      stats[:controls_parented_count].should eq(1)
    end
  end
end
