require 'spec_helper'
require 'base_objects'

describe MappingController do
  include BaseObjects

  describe "GET 'index' without authorization" do
    it "fails as guest" do
      login({}, {})
      create_base_objects
      get 'show', :program_id => @reg.id
      response.should be_redirect
    end
  end

  context "authorized" do
    before :each do
      login({}, { :role => 'admin' })
      create_base_objects
      @cctl = FactoryGirl.create(:control, :title => 'Company ctl 1', :slug => 'COM1-CTL2', :description => 'x', :program => @creg);
    end

    describe "GET 'show'" do
      it "returns http success" do
        get 'show', :program_id => @reg.id
        assigns(:program).should eq(@reg)
        assigns(:rcontrols).should eq([@ctl])
        assigns(:ccontrols).should eq([@cctl])
        response.should be_success
      end
    end

    describe "GET 'buttons'" do
      it "has nothing selected" do
        get 'buttons', :format => :json, :section => '', :rcontrol => '', :ccontrol => ''
        JSON.parse(response.body).should eq([false, false])
      end
      it "has no mappings" do
        get 'buttons', :format => :json, :section => @sec.id, :rcontrol => @ctl.id, :ccontrol => @cctl.id
        JSON.parse(response.body).should eq([false, false])
      end
      it "has reg mappings" do
        FactoryGirl.create(:control_section, :section_id => @sec.id, :control_id => @ctl.id)
        get 'buttons', :format => :json, :section => @sec.id, :rcontrol => @ctl.id, :ccontrol => @cctl.id
        JSON.parse(response.body).should eq([true, false])
      end
      it "has both mappings" do
        FactoryGirl.create(:control_section, :section_id => @sec.id, :control_id => @ctl.id)
        FactoryGirl.create(:control_control, :control_id => @cctl.id, :implemented_control_id => @ctl.id)
        get 'buttons', :format => :json, :section => @sec.id, :rcontrol => @ctl.id, :ccontrol => @cctl.id
        JSON.parse(response.body).should eq([true, true])
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
