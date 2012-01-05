require 'spec_helper'

describe Admin::PeopleController do
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
      @person = Person.create(:username => 'user1')
    end

    describe "GET 'index'" do
      it "returns http success" do
        get 'index'
        response.should be_success
        assigns(:people).should eq([@person])
      end
    end
  end

end
