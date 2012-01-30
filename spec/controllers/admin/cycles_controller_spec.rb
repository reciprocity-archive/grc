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

    describe "PUT 'update'" do
      it "updates an existing object" do
        test_controller_update(:cycle, @cycle, :start_at => Date.parse('2012-01-01'))
      end
    end
  end

end
