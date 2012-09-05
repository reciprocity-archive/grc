require 'spec_helper'
require 'authorized_controller'

describe Admin::PeopleController do
  before :each do
    @person = FactoryGirl.create(:person, :email => 'user1@example.com')
    @object = @person
    @index_objs = [@person]
  end

  it_behaves_like "an authorized controller"
end
