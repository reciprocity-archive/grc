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
  
  context 'role restriction' do
    it 'should derive risk permissions from role field' do
      person = FactoryGirl.create(:person, :role => 'User')
      person.can_manage_risk.should == false
      person = FactoryGirl.create(:person, :role => 'Risk')
      person.can_manage_risk.should == true
    end
    
    it 'should not allow risks to be retrieved '
  end

  context "authorization" do
    it "should do the right thing with no object"
    it "should do the right thing with an object"
  end
end
