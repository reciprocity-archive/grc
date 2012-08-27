require 'spec_helper'

describe TestreportController do
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
      @ctl2 = FactoryGirl.create(:control, :title => 'Control 2', :slug => 'reg1-ctl2', :description => 'x', :program => @reg, :is_key => true, :fraud_related => false)
      @sys = FactoryGirl.create(:system, :title => 'System 1', :slug => 'sys1', :description => 'x', :infrastructure => true)
      @sc = FactoryGirl.create(:system_control, :control => @ctl, :system => @sys, :state => :green, :cycle => @cycle)
      @sc2 = FactoryGirl.create(:system_control, :control => @ctl2, :system => @sys, :state => :green, :cycle => @cycle)
      @bp = BizProcess.create(:title => 'Biz Process 1', :slug => 'bp1', :description => 'x')
      @bp.controls = [@ctl]
      @bp.save!
      session[:cycle_id] = @cycle.id
    end

    describe "GET 'index'" do
      it "returns http success" do
        get 'index'
        response.should be_success
      end
    end

    describe "GET on some actions" do
      %w{top byprogram byprocess}.each do |action|
        it "GET '#{action}'" do
          get action
          response.should be_success
          assigns(:system_controls).should eq([@sc, @sc2])
        end
      end
    end

    describe "POST to some actions" do
      %w{top byprogram}.each do |action|
        it "POST '#{action}' redirects" do
          post action
          response.should be_redirect
        end
      end
    end

    describe "POST 'byprocess'" do
      it "handles without biz_process" do
        post 'byprocess', :biz_process => {:id => ''}
        response.should be_success
        assigns(:system_controls).should eq([@sc, @sc2])
      end

      it "handles with biz_process" do
        post 'byprocess', :biz_process => {:id => @bp.id}
        response.should be_success
        assigns(:system_controls).should eq([@sc])
        assigns(:biz_process).should eq(@bp)
      end
    end
  end

end
