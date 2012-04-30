require 'spec_helper'
require 'base_objects'

describe Admin::ProgramsController do
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
        assigns(:programs).should eq([@reg])
      end
    end

    describe "POST 'create'" do
      it "creates a new object" do
        test_controller_create(:program, :title => "reg2", :slug => 'REG2')
      end
    end

    describe "PUT 'update'" do
      it "updates an existing object" do
        test_controller_update(:program, @reg, :title => "reg1a")
      end
    end
  end

end
