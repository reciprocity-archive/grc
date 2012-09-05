require 'spec_helper'
require 'authorized_controller'

describe DashboardController do

  before :each do
    @reg = FactoryGirl.create(:program, :title => 'Reg 1', :slug => 'reg1', :company => false)
    @cycle = FactoryGirl.create(:cycle, :program => @reg, :start_at => '2012-01-01')
    @bp = FactoryGirl.create(:biz_process, :title => 'Biz Process 1', :slug => 'bp1', :description => 'x')
    @sys = FactoryGirl.create(:system, :title => 'System 1', :slug => 'sys1', :description => 'x', :infrastructure => true)

    @model = BizProcess
    @index_objs = [@bp]
  end

  it_behaves_like "an admin controller"

  context "authorized" do
    before :each do
      login({}, { :role => 'admin' })
      #BizProcess.destroy
      #System.destroy
      @locals = Hash.new(0)
      session[:cycle_id] = @cycle.id
    end


    describe "POST 'index'" do
      it "redirects" do
        post 'index'
        response.should be_redirect
      end
    end

    describe "GET 'openbp'" do
      it "returns http success" do
        get 'openbp', :id => @bp.id
        response.should be_success
        #assert_template :partial => '_openbp', :locals => { :bp => @bp }
        # cannot test locals because of a bug in ActionController::TestCase
      end
    end

    describe "GET 'closebp'" do
      it "returns http success" do
        get 'closebp', :id => @bp.id
        response.should be_success
        #assert_template :partial => '_closebp', :locals => { :bp => @bp }
      end
    end

    describe "GET 'opensys'" do
      it "returns http success" do
        get 'opensys', :id => @sys.id, :biz_process_id => @bp.id
        response.should be_success
        #assert_template :partial => '_opensys', :locals => { :biz_process => @bp, :system => @sys }
      end
    end

    describe "GET 'closesys'" do
      it "returns http success" do
        get 'closesys', :id => @sys.id, :biz_process_id => @bp.id
        #assert_template :partial => '_closesys', :locals => { :biz_process => @bp, :system => @sys }
      end
    end
  end

end
