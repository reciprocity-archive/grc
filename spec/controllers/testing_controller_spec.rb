require 'spec_helper'

describe TestingController do
  describe "GET 'index' without authorization" do
    it "fails as guest" do
      login({}, {})
      get 'index'
      response.should be_redirect
    end
  end

  context "authorized" do
    before :each do
      login({}, { :role => 'admin' })

      @reg = FactoryGirl.create(:program, :title => 'Reg 1', :slug => 'reg1', :company => false)
      @cycle = FactoryGirl.create(:cycle, :program => @reg, :start_at => '2012-01-01')
      @ctl = FactoryGirl.create(:control, :title => 'Control 1', :slug => 'reg1-ctl1', :description => 'x', :program => @reg, :is_key => true, :fraud_related => false)
      @sys = FactoryGirl.create(:system, :title => 'System 1', :slug => 'sys1', :description => 'x', :infrastructure => true)
      @sc = FactoryGirl.create(:system_control, :control => @ctl, :system => @sys, :state => :green, :cycle => @cycle)
      @desc = FactoryGirl.create(:document_descriptor, :title => 'ACL')
      @doc = FactoryGirl.create(:document, :link => 'http://cde.com/', :title => 'Cde')
      session[:cycle_id] = @cycle.id
    end

    describe "GET 'index'" do
      it "returns http success" do
        get 'index'
        response.should be_success
        assigns(:systems).should eq([@sys])
      end
    end

    describe "POST 'index'" do
      it "redirects" do
        post 'index'
        response.should be_redirect
      end
    end

    describe "GET 'show_closed'" do
      it "returns http success" do
        get 'show_closed', :system_id => @sys.id, :control_id => @ctl.id
        response.should be_success
        assert_template :partial => '_closed_control'
        #, :locals => { :sc => @sc }
        # cannot test locals because of a bug in ActionController::TestCase
      end
    end

    describe "GET 'show'" do
      it "returns http success" do
        get 'show', :system_id => @sys.id, :control_id => @ctl.id
        response.should be_success
        assert_template :partial => '_control'
      end
    end

    describe "GET 'edit_control_text'" do
      it "returns http success" do
        get 'edit_control_text', :system_id => @sys.id, :control_id => @ctl.id
        response.should be_success
        assert_template :partial => '_control_text_form'
      end
    end

    describe "POST 'update_control_text'" do
      it "returns http success" do
        get 'update_control_text', :system_id => @sys.id, :control_id => @ctl.id, :system_control => { :test_why => 'why1' }
        response.should be_success
        @sc.reload
        @sc.test_why.should eq('why1')
        assert_template :partial => '_control'
      end
    end

    describe "POST 'update_control_state'" do
      it "returns http success" do
        get 'update_control_state', :system_id => @sys.id, :control_id => @ctl.id, :value => :red
        response.should be_success
        @sc.reload
        @sc.state.should eq(:red)
        assert_template :partial => '_control'
      end
    end

    describe "POST 'review'" do
      it "reviews a regular doc" do
        post 'review', :document_id => @doc.id, :value => 1
        response.should be_success
        assert_template :partial => '_document'
        @doc.reload
        @doc.reviewed.should be_true
        @doc.good.should be_true

        post 'review', :document_id => @doc.id, :value => 'maybe'
        response.should be_success
        assert_template :partial => '_document'
        @doc.reload
        @doc.reviewed.should be_false
        @doc.good.should be_false
      end
    end

  end

end
