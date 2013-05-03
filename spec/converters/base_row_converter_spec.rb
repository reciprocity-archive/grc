require 'spec_helper'

describe BaseRowConverter do
  context 'uploading a CSV' do
    it "should not accept multiple slugs" do
      person = FactoryGirl.create(:person, :email => 'exists@example.com')
      account = FactoryGirl.create(:account, :email => 'exists@example.com')
      account.person.should eq(person)
    end
  end
end
