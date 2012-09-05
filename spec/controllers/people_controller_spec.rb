require 'spec_helper'
require 'authorized_controller'

describe PeopleController do
  before :each do
    @model = Person
    @object = FactoryGirl.create(:person)
    @program = FactoryGirl.create(:program)
  end

  context "authorization" do
    it_behaves_like "an authorized create"
    it_behaves_like "an authorized new"
    it_behaves_like "an authorized update", ['edit', 'update']
    it_behaves_like "an authorized action", ['list'], 'read_person'
    it_behaves_like "an authorized action", ['list_update', 'list_edit'], 'update_person'
  end

  context "list_update" do
    it "should add a new user" do
      login({}, {:role => :admin})
      post 'list_update', {
        :object_type => 'program',
        :object_id => @program.id,
        :items => {1 => {:id => @object.id}}
      }
      response.should be_success
    end
  end

  context "list_edit" do
    it "should show the right objects" do
      login({}, {:role => :admin})
      get 'list_edit', {
        :object_type => 'program',
        :object_id => @program.id,
      }
      response.should be_success
    end
  end
end
