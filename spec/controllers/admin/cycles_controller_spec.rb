require 'spec_helper'
require 'base_objects'

describe Admin::CyclesController do
  include BaseObjects

  describe "GET 'index' without authorization" do
    it "fails as guest" do
      login({}, {})
      get 'index'
      response.should be_redirect
    end
  end

  describe "authorized" do
    before :each do
      login({}, { :role => 'admin' })
      create_base_objects
    end

    describe "GET 'index'" do
      it "returns http success" do
        get 'index'
        response.should be_success
        assigns(:cycles).should eq([@cycle])
      end
    end

    describe "POST 'create'" do
      it "creates a new object" do
        test_controller_create(:cycle, :regulation_id => @reg.id, :start_at => Date.parse('2012-02-02'))
      end
    end

    describe "PUT 'update'" do
      it "updates an existing object" do
        test_controller_update(:cycle, @cycle, :start_at => Date.parse('2012-01-01'))
      end
    end

    describe "clone" do
      it "shows clone form" do
        get 'new_clone', :id => @cycle.id
        response.should be_success
        assigns(:cycle).regulation.should eq(@reg)
        assigns(:cycle).start_at.should eq(@cycle.start_at)
      end
      it "clones do" do
        post 'clone', :id => @cycle.id, :cycle => { :start_at => '2012-02-02' }
        response.should be_redirect
        assigns(:cycle).regulation.should eq(@reg)
        assigns(:cycle).start_at.should eq(Date.parse('2012-02-02'))
        assigns(:cycle).new_record?.should be_false
        SystemControl.where(:control_id => @ctl, :system_id => @sys, :cycle_id => assigns(:cycle)).size.should eq(1)
      end
    end
  end

end
