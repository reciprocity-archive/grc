require 'spec_helper'
require 'authorized_controller'

describe UserSessionsController do
  context "login" do
    it "should render properly when not logged in" do
      get 'login'
      response.should be_success
    end

    it "should render properly when not logged in" do
      get 'login'
      response.should be_success
    end
  end

  context "create" do
    it "should handle failure properly" do
      post 'create', :user_session => {
        :email => 'foo@bar.com'
      }
      response.should be_unauthenticated
    end
    it "should handle success properly" do
      @account = FactoryGirl.create(:account, :email => 'foo@bar.com', :password => 'foobar', :password_confirmation => 'foobar', :role => :user)
      post 'create', :user_session => {
        :email => 'foo@bar.com',
        :password => 'foobar'
      }

      response.should be_success_or_redirect
      response.should_not be_unauthorized
    end
  end

  context "destroy" do
    it "should delete the session and not allow you to view pages" do
      pending "figure out how to wrangle sessions properly using rspec"
    end
  end
end
