require 'spec_helper'
require 'base_objects'

describe Admin::ControlsController do
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
        assigns(:controls).should eq([@ctl])
      end
    end

    describe "PUT 'update'" do
      it "updates an existing object" do
        @ctl.control_objectives.should eq([])
        test_controller_update(:control, @ctl, :description => "desc2", :co_ids => [@co.id])
        @ctl.reload
        @ctl.control_objectives.should eq([@co])
      end
    end
  end

end
