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
    it_behaves_like "an authorized delete"
    it_behaves_like "an authorized action", ['list'], 'read_person'
    it_behaves_like "an authorized action", ['list_update', 'list_edit'], 'update_person'
  end

  context "list_update" do
    it "should add a new user with a role" do
      login({}, {:role => :superuser})
      post 'list_update', {
        :object_type => 'program',
        :object_id => @program.id,
        :items => {1 => {:id => @object.id, :role => 'owner'}}
      }
      response.should be_success
      @program.people.should include @object
      role = @program.object_people.where(:person_id => @object.id).first.role
      role.should eq 'owner'
    end

    it "should not add a new user without a role" do
      login({}, {:role => :superuser})
      post 'list_update', {
        :object_type => 'program',
        :object_id => @program.id,
        :items => {1 => {:id => @object.id}}
      }
      response.should be_success
      @program.people.should_not include @object
    end

    it "should update role for existing users" do
      login({}, {:role => :superuser})
      @program.object_people.create(
        {:person => @object, :role => 'none'},
        :without_protection => true)
      role = @program.object_people.where(:person_id => @object.id).first.role
      role.should eq 'none'
      post 'list_update', {
        :object_type => 'program',
        :object_id => @program.id,
        :items => {1 => {:id => @object.id, :role => 'owner'}}
      }
      response.should be_success
      role = @program.object_people.reload.where(:person_id => @object.id).first.role
      role.should eq 'owner'
    end
  end

  context "list_edit" do
    it "should show the right objects" do
      login({}, {:role => :superuser})
      get 'list_edit', {
        :object_type => 'program',
        :object_id => @program.id,
      }
      response.should be_success
    end
  end
end
