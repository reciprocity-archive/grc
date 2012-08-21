require 'spec_helper'

describe QuickController do
  it "should test all search results for allowed scoping"

  context "authorization" do
    before :each do
      login({}, {:role => 'admin'})
    end

    context "programs" do
      before :each do
        get 'programs', :s => 'foo'
      end
      it "should succeed" do
        response.should be_success
      end

      it "should properly filter program" do
        pending "enable authorization filtering"
        assigns(:programs).should eq([])
      end
    end

    context "sections" do
      before :each do
        get 'sections', :s => 'foo'
      end

      it "should succeed" do
        response.should be_success
      end

      it "should properly filter sections" do
        pending "enable authorization filtering"
        assigns(:sections).should eq([])
      end
    end

    context "controls" do
      before :each do
        get 'controls', :s => 'foo'
      end

      it "should succeed" do
        response.should be_success
      end

      it "should properly filter sections" do
        pending "enable authorization filtering"
        assigns(:controls).should eq([])
      end
    end

    context "biz_processes" do
      before :each do
        get 'biz_processes', :s => 'foo'
      end

      it "should succeed" do
        response.should be_success
      end

      it "should properly filter biz_processes" do
        pending "enable authorization filtering"
        assigns(:biz_processes).should eq([])
      end
    end

    context "accounts" do
      before :each do
        get 'accounts', :s => 'foo'
      end

      it "should succeed" do
        response.should be_success
      end

      it "should properly filter sections" do
        pending "enable authorization filtering"
        assigns(:accounts).should eq([])
      end
    end

    context "people" do
      before :each do
        get 'people', :s => 'foo'
      end

      it "should succeed" do
        response.should be_success
      end

      it "should properly filter sections" do
        pending "enable authorization filtering"
        assigns(:people).should eq([])
      end
    end

    context "systems" do
      before :each do
        get 'systems', :s => 'foo'
      end

      it "should succeed" do
        response.should be_success
      end

      it "should properly filter sections" do
        pending "enable authorization filtering"
        assigns(:systems).should eq([])
      end
    end
  end
end