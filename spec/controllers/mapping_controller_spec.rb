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
      @cctl = Control.create(:title => 'Company ctl 1', :slug => 'COM1-CTL2', :description => 'x', :program => @creg);
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
  end
end
