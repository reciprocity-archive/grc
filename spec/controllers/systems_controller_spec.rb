require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe SystemsController do
  include BaseObjects

  context "authorization" do
    before :each do
      create_base_objects

      # For use by authorized_controller tests
      @model = System
      @object = @sys
    end

    it_behaves_like "an authorized create", ['import']
    it_behaves_like "an authorized new"
    it_behaves_like "an authorized read", ['tooltip']
    it_behaves_like "an authorized update", ['edit', 'update']
    it_behaves_like "an authorized delete"
  end

  context "export" do
    before :each do
      login({}, { :role => 'superuser' })
    end
    it "should export" do
      @reg.audit_duration = Option.create(:title => "1 Week", :role => 'audit_duration')
      @reg.audit_frequency = Option.create(:title => "Often", :role => 'audit_frequency')
      @reg.save
      get 'export', :id => @reg.id, :format => :csv
      # program titles, 1 program, blank line, section titles, 1 section
      response.body.split("\n").size.should == 5
      (response.body =~ /1 Week/).should_not be_nil
      (response.body =~ /Often/).should_not be_nil
    end
  end

  context "import" do
    before :each do
      login({}, { :role => 'superuser' })
    end

    it "should prepare import" do
      post 'import', :upload => fixture_file_upload("/SYS.csv")
      assigns(:messages).should == []
      assigns(:creates).should == [ 'SYS1', 'SYS2' ]
      assigns(:updates).should == []
      assigns(:errors).should == {}
      System.find_by_slug('SYS1').should be_nil
    end

    it "should do import" do
      post 'import', :upload => fixture_file_upload("/SYS.csv"), :confirm => true
      assigns(:messages).should == []
      assigns(:creates).should == [ 'SYS1', 'SYS2' ]
      assigns(:updates).should == []
      assigns(:errors).should == {}
      System.find_by_slug('SYS1').title.should == 'System 1'
      System.find_by_slug('SYS1').infrastructure.should be_true
      System.find_by_slug('SYS2').infrastructure.should be_false
    end
  end
end
