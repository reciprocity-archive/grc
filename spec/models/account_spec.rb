require 'spec_helper'

describe Account do
  context 'associating with people' do
    it "should associate with a matching person if the e-mail matches" do
      person = FactoryGirl.create(:person, :email => 'exists@example.com')
      account = FactoryGirl.create(:account, :email => 'exists@example.com')
      account.person.should eq(person)
    end

    it "should not overwrite a set person association" do
      person = FactoryGirl.create(:person, :email => 'exists@example.com')
      account = FactoryGirl.create(:account, :email => 'exists@example.com', :person => person)
      account.person.should eq(person)
    end

    it "should create a person if there isn't one that matches" do
      account = FactoryGirl.create(:account)
      account.person.should_not eq(nil)
    end
  end

  context "authorization" do
    it "should do the right thing with no object"
    it "should do the right thing with an object"
  end
end
