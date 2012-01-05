require 'spec_helper'

describe Admin::AccountsController do
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
      @account = Account.create(:email => 'a@b.com', :role => 'analyst', :password => '1111', :password_confirmation => '1111')
    end

    describe "GET 'index'" do
      it "returns http success" do
        get 'index'
        response.should be_success
        assigns(:accounts).should eq([@account])
      end
    end
  end

end
