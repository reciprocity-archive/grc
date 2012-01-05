require 'spec_helper'
require 'base_objects'

describe Admin::SystemsController do
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
        assigns(:systems).should eq([@sys])
      end
    end

    describe "POST 'create'" do
      it "creates a new object" do
        test_controller_create(:system, :title => "sys2", :slug => 'SYS2', :description => "sys 2", :infrastructure => true)
      end
    end

    describe "PUT 'update'" do
      it "updates an existing object" do
        test_controller_update(:system, @sys, :title => "sys1a")
      end
    end
  end

end
