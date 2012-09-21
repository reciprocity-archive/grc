require 'spec_helper'

describe WelcomeController do
  context "index" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end

    it "should redirect when logged in" do
      login({}, {:role => :superuser})
      get 'index'
      response.should be_redirect
    end
  end

  context "login_dispatch" do
    it "should redirect to index when not logged in" do
      get 'login_dispatch'
      response.should redirect_to(root_url)
    end

    it "should redirect to placeholder when auditor logged in" do
      login({}, {:role => :auditor})
      get 'login_dispatch'
      response.should redirect_to(placeholder_url)
    end

    it "should redirect to programs_dash for users of non-auditor roles" do
      login({}, {:role => :superuser})
      get 'login_dispatch'
      response.should redirect_to(programs_dash_url)
    end
  end
end
