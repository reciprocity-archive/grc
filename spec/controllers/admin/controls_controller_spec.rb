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

    describe "POST 'create'" do
      it "creates a new object" do
        test_controller_create(:control, :program_id => @reg.id, :title => 'ctlx', :description => 'descx', :slug => "REG1-CX")
      end
    end

    describe "PUT 'update'" do
      it "updates an existing object" do
        @ctl.sections.should eq([])
        test_controller_update(:control, @ctl, :description => "desc2", :section_ids => [@co.id])
        @ctl.reload
        @ctl.sections.should eq([@co])
      end
    end
  end

end
