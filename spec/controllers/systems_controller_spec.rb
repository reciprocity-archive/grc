require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe SystemsController do
  include BaseObjects

  before :each do
    create_base_objects

    # For use by authorized_controller tests
    @model = System
    @object = @sys
  end

  context "authorization" do
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
      get 'export', :id => @sys.id, :format => :csv
      # system titles, system data
      response.body.split("\n").size.should == 2
    end
  end

  context "import" do
    before :each do
      login({}, { :role => 'superuser' })
    end

    it "should prepare import" do
      post 'import', :upload => fixture_file_upload("/SYS.csv")
      assigns(:messages).should == []
      assigns(:creates).should == [ 'SYS2' ]
      assigns(:updates).should == [ 'SYS1' ]
      assigns(:errors).should == {}
      System.find_by_slug('SYS2').should be_nil
    end

    it "should do import" do
      post 'import', :upload => fixture_file_upload("/SYS.csv"), :confirm => true
      assigns(:messages).should == []
      assigns(:creates).should == [ 'SYS2' ]
      assigns(:updates).should == [ 'SYS1' ]
      assigns(:errors).should == {}
      System.find_by_slug('SYS1').title.should == 'System 1'
      System.find_by_slug('SYS1').infrastructure.should be_true
      System.find_by_slug('SYS2').infrastructure.should be_false
    end
  end
end
