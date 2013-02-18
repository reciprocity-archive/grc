require 'spec_helper'
require 'authorized_controller'

describe ObjectPeopleController do
  before :each do
    @model = ObjectPerson
    @object = FactoryGirl.create(:object_person)
    @person = FactoryGirl.create(:person)
    @directive = FactoryGirl.create(:directive)
    @create_params = {
      :personable_type => @directive.class.name,
      :personable_id => @directive.id,
      :person_id => @person.id
    }
    @index_objs = [@object]
  end

  context "authorization" do
    it_behaves_like "an authorized index"
    it_behaves_like "an authorized create"
    #it_behaves_like "an authorized action", ['list_edit'], 'update_person'
  end

  context "create" do
    it "should add a new user with a role" do
      login({}, {:role => :superuser})
      post 'create', {
        :items => {1 => {
          :person_id => @person.id,
          :role => 'owner',
          :personable_type => @directive.class.name,
          :personable_id => @directive.id,
        }}
      }
      response.should be_success
      @directive.people.should include @person
      role = @directive.object_people.where(:person_id => @person.id).first.role
      role.should eq 'owner'
    end

    it "should not add a new user without a role" do
      login({}, {:role => :superuser})
      post 'create', {
        :items => {1 => {
          :person_id => @person.id,
          :personable_type => @directive.class.name,
          :personable_id => @directive.id,
        }}
      }
      response.should_not be_success
      @directive.people.should_not include @person
    end

    it "should update role for existing users" do
      login({}, {:role => :superuser})
      @directive.object_people.create(
        {:person => @person, :role => 'none'},
        :without_protection => true)
      object_person = @directive.object_people.where(:person_id => @person.id).first
      role = object_person.role
      role.should eq 'none'
      post 'create', {
        :items => { object_person.id => {
          :id => object_person.id,
          :person_id => @person.id,
          :role => 'owner',
          :personable_type => @directive.class.name,
          :personable_id => @directive.id
        }}
      }
      response.should be_success
      role = @directive.object_people.reload.where(:person_id => @person.id).first.role
      role.should eq 'owner'
    end
  end

  context "list_edit" do
    it "should show the right objects" do
      login({}, {:role => :superuser})
      get 'list_edit', {
        :object_type => @directive.class.name,
        :object_id => @directive.id,
      }
      response.should be_success
    end
  end
end

