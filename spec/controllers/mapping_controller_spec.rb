require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe MappingController do
  include BaseObjects

  describe "GET 'index' without authorization" do
    it "fails as guest" do
      # FIXME: rewrite this using the shared authorization controller tests
      login({}, {})
      create_base_objects
      get 'show', :program_id => @prog.id
      response.should be_unauthorized
    end
  end

  context "authorized" do
    before :each do
      login({}, { :role => 'superuser' })
      create_base_objects
      @cctl = FactoryGirl.create(:control, :title => 'Company ctl 1', :slug => 'COM1-CTL2', :description => 'x', :directive => @creg);
    end

    describe "GET section_dialog" do
      it "returns success" do
        get 'section_dialog', :section_id => @sec.id
        response.should be_success
        assigns(:section).should eq(@sec)
      end
    end

    describe "update" do
      it "returns success" do
        put 'update', :section_id => @sec.id, :section => {'na' => 'foo', 'notes' => 'bar'}
        response.should be_success
      end
    end

    describe "GET 'show'" do
      it "returns http success" do
        get 'show', :program_id => @prog.id
        assigns(:program).should eq(@prog)
        response.should be_success
      end
    end

    describe "does mapping" do
      it "maps reg" do
        get 'map_rcontrol', :section => @sec.id, :rcontrol => @ctl.id
        ControlSection.count.should eq(1)

        get 'map_rcontrol', :section => @sec.id, :rcontrol => @ctl.id, :u => 1
        ControlSection.count.should eq(0)
      end
      it "maps company" do
        get 'map_ccontrol', :ccontrol => @cctl.id, :rcontrol => @ctl.id
        ControlControl.count.should eq(1)

        get 'map_ccontrol', :ccontrol => @cctl.id, :rcontrol => @ctl.id, :u => 1
        ControlControl.count.should eq(0)
      end
      it "maps section directly to company" do
        get 'map_rcontrol', :section => @sec.id, :ccontrol => @cctl.id
        ControlSection.count.should eq(1)
        ControlControl.count.should eq(1)
      end
    end
  end
end
