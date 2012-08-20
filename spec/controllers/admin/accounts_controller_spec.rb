require 'spec_helper'
require 'base_objects'

describe Admin::AccountsController do
  include BaseObjects

  describe "GET 'index' without authorization" do
    it "fails as guest" do
      test_unauth
    end
  end

  describe "authorized" do
    before :each do
      login({}, { :role => 'superuser' })
      @account = FactoryGirl.create(:account, :email => 'a@b.com', :role => 'analyst', :password => '1111', :password_confirmation => '1111')
    end
    describe "GET 'index'" do
      it "returns http success" do
        test_controller_index(:accounts, [@account])
      end
    end


    describe "PUT 'update'" do
      it "updates an existing object" do
        @account.valid_password?("2222").should be_false
        test_controller_update(:account, @account, :password => "2222", :password_confirmation => '2222')
        @account.reload
        @account.valid_password?("2222").should be_true
      end
    end

  end

end
