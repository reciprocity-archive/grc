require 'spec_helper'

describe EvidenceController do
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
      @ctl = FactoryGirl.create(:control, :title => 'Control 1', :slug => 'reg1-ctl1', :description => 'x', :program => @reg, :is_key => true, :fraud_related => false)
      @sys = FactoryGirl.create(:system, :title => 'System 1', :slug => 'sys1', :description => 'x', :infrastructure => true)
      @sys2 = FactoryGirl.create(:system, :title => 'System 2', :slug => 'sys2', :description => 'x', :infrastructure => true)
      @cycle = FactoryGirl.create(:cycle, :program => @reg, :start_at => '2012-01-01')
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

    describe "GET 'show_closed_control'" do
      it "returns http success" do
        get 'show_closed_control', :system_id => @sys.id, :control_id => @ctl.id
        response.should be_success
        assert_template :partial => '_closed_control'
        #, :locals => { :sc => @sc }
        # cannot test locals because of a bug in ActionController::TestCase
      end
    end

    describe "GET 'show_control'" do
      it "returns http success" do
        get 'show_control', :system_id => @sys.id, :control_id => @ctl.id
        response.should be_success
        assert_template :partial => '_control'
      end
    end

    describe "GET 'new'" do
      it "returns http success" do
        get 'new', :system_id => @sys.id, :control_id => @ctl.id, :descriptor_id => @desc
        response.should be_success
        assert_template :partial => '_attach_form'
        assigns(:document).should_not be_nil
      end
    end

    describe "GET 'new_gdoc'" do
      pending
    end

    describe "POST 'attach'" do
      it "attaches a regular doc" do
        pending
        attrs = { :link => 'http://abc.com/', :title => 'Abc' }
        post 'attach', :system_id => @sys.id, :control_id => @ctl.id, :descriptor_id => @desc, :document => attrs
        response.should be_redirect
        @sc.evidences.reload
        @sc.evidences.should have(1).items
        @sc.evidences[0].link.to_s.should eq('http://abc.com/')
      end
      it "attaches a gdoc" do
        pending
      end
    end

    describe "GET 'show'" do
      it "returns http success" do
        get 'show', :document_id => @doc.id
        response.should be_success
        assert_template :partial => '_document'
      end
    end

    describe "POST 'update'" do
      it "updates a regular doc" do
        attrs = { :link => 'http://abc.com/', :title => 'Abc' }
        post 'attach', :system_id => @sys.id, :control_id => @ctl.id, :descriptor_id => @desc, :document => attrs
        response.should be_redirect
        @sc.evidences.should have(1).items

        post 'update', :document_id => @sc.evidences[0].id, :document => { :title => 'Abc1' }
        response.should be_success
        assert_template :partial => '_document'
        @sc.evidences.reload
        @sc.evidences[0].title.to_s.should eq('Abc1')
      end
    end

    describe "POST 'destroy'" do
      it "destroys a regular doc" do
        attrs = { :link => 'http://abc.com/', :title => 'Abc' }
        post 'attach', :system_id => @sys.id, :control_id => @ctl.id, :descriptor_id => @desc, :document => attrs
        response.should be_redirect
        @sc.evidences.should have(1).items

        post 'destroy', :system_id => @sys.id, :control_id => @ctl.id, :document_id => @sc.evidences[0].id
        response.should be_redirect
        @sc.evidences.reload
        @sc.evidences.should have(0).items
      end
      it "destroys a gdoc" do
        pending
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
