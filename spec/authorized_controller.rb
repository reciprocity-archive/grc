# Test some of the authorization basics for resource controllers.

#
# Usage:
#
# require 'authorized_controller'
#
# before :each do
#   @model = <model> # The model that you're testing authorization for, e.g. Account
#   @object = <obj> # An instance you want to test read and update actions against
#   @index_objs = [<obj1>,<obj2>] # A list of objects that should be visible when
#                                 # an authenticated 'index' action is performed
#   @create_params = {} # Parameters to pass into the authorized create test
# end
#
# it_behaves_like "an authorized create"
# it_behaves_like "an authorized new"
# it_behaves_like "an authorized index"
# it_behaves_like "an authorized delete"
# it_behaves_like "an authorized read", [<action1>, <action2>] # actions are optional, defaults to 'show'
# it_behaves_like "an authorized update", [<action1>, <action2>] # actions are optional, defaults to 'edit'
# it_behaves_like "an authorized action", [<action1>, <action2>], <ability> # Tests basic authorization for any action

# FIXME: Should (based on parameters) automatically test
# multiple login roles.

# Helper functions for specs, makes it easier to write specs for authorization
class BeSuccessOrRedirect
  def matches?(target)
    @target = target
    [200, 302, 279].include? target.status
  end

  def failure_message
    "expected to succeed or redirect, got #{@target.status}"
  end

  def negative_failure_message
    "expected not to succeed or redirect, got #{@target.status}"
  end
end

def be_success_or_redirect
  BeSuccessOrRedirect.new
end

class BeUnauthorized
  def initialize
  end

  def matches?(target)
    @target = target
    target.status == 403
  end

  def failure_message
    "expected to be unauthorized, got #{@target.status}"
  end

  def negative_failure_message
    "expected to not be unauthorized, got #{@target.status}"
  end
end

def be_unauthorized
  BeUnauthorized.new
end

class BeUnauthenticated
  def matches?(target)
    @target = target
    target.status == 401
  end

  def failure_message
    "expected to be unauthenticated, got #{@target.status}"
  end

  def negative_failure_message
    "expected to not be unauthenticated, got #{@target.status}"
  end
end

def be_unauthenticated
  BeUnauthenticated.new
end


shared_examples_for "an authorized create" do
  context "not logged in" do
    it "is unauthenticated" do
      post 'create'
      response.should be_unauthenticated
    end
  end

  context "logged in w/o create" do
    before :each do
      login({}, {})
    end
    it "is unauthorized" do
      post 'create'
      response.should be_unauthorized
    end
  end

  context "logged in w/ create" do
    before :each do
      login({}, {:role => 'create_' + @model.table_name.singularize})
    end

    it "authorizes and creates" do
      post 'create', @model.table_name.singularize.to_sym => @create_params || {}

      # Note: The operation may still fail, just not due to
      # an authorization issue.
      response.should_not be_unauthorized
      # FIXME: Should test for the existence of the new record
    end
  end
end

shared_examples_for "an authorized new" do
  context "not logged in" do
    it "is unauthenticated" do
      get 'new'
      response.should be_unauthenticated
    end
  end

  context "logged in w/o new" do
    before :each do
      login({}, {})
    end
    it "is unauthorized" do
      get 'new'
      response.should be_unauthorized
    end
  end

  context "logged in w/ create" do
    before :each do
      login({}, {:role => 'create_' + @model.table_name.singularize})
    end

    it "authorized and creates" do
      get 'new'
      # Note: The operation may still fail, just not due to
      # an authorization issue.
      response.should_not be_unauthorized
      assigns(@model.table_name.singularize).class.should eq(@model)
    end
  end
end

shared_examples_for "an authorized read" do |actions|
  if !actions
    actions = ['show']
  end
  context "not logged in" do
    actions.each do |action|
      if described_class.action_methods.include? action
        it "should fail for: #{action}" do
          get action, :id => @object.id
          response.should be_unauthenticated
        end
      end
    end
  end

  context "logged in w/o read" do
    before :each do
      login({}, {})
    end
    actions.each do |action|
      if described_class.action_methods.include? action
        it "should be unauthorized for: #{action}" do
          get action, :id => @object.id
          response.should be_unauthorized
        end
      end
    end
  end

  context "logged in with read" do
    before :each do
      login({}, {:role => 'read'})
    end
    actions.each do |action|
      if described_class.action_methods.include? action
        it "should be authorized w/ read for: #{action}" do
          get action, :id => @object.id
          response.should be_success_or_redirect
          assigns(@object.class.table_name.singularize.to_sym).should eq(@object)
        end
      end
    end
  end
end

shared_examples_for "an authorized index" do
  context "not logged in" do
    it "should fail for: index" do
      get 'index'
      response.should be_unauthenticated
    end
  end

  context "logged in w/o read" do
    before :each do
      login({}, {})
    end

    it "should be unauthorized for: index" do
      get 'index'
      response.should be_unauthorized
    end
  end

  context "logged in with read" do
    before :each do
      login({}, {:role => :reader})
    end

    it "should be authorized w/ read for: index" do
      get 'index'
      response.should be_success_or_redirect
      assigns(@model.table_name.to_sym).should eq(@index_objs)
    end
  end
end

shared_examples_for "an authorized edit" do |actions|
  if !actions
    actions = ['edit']
  end

  context "not logged in" do
    actions.each do |action|
      if described_class.action_methods.include? action
        it "should fail for: #{action}" do
          get action, :id => @object.id
          response.should be_unauthenticated
        end
      end
    end
  end

  context "logged in w/o update" do
    before :each do
      login({}, {})
    end
    actions.each do |action|
      if described_class.action_methods.include? action
        it "should be unauthorized for: #{action}" do
          get action, :id => @object.id
          response.should be_unauthorized
        end
      end
    end
  end

  context "logged in with update" do
    before :each do
      login({}, {:role => 'update_' + @model.table_name.singularize})
    end
    actions.each do |action|
      if described_class.action_methods.include? action
        it "should be authorized w/ edit for: #{action}" do
          get action, :id => @object.id
          response.should be_success_or_redirect
          assigns(@object.class.table_name.singularize.to_sym).should eq(@object)
        end
      end
    end
  end
end

shared_examples_for "an authorized update" do |actions|
  if !actions
    actions = ['update']
  end

  context "not logged in" do
    actions.each do |action|
      if described_class.action_methods.include? action
        it "is unauthorized for: #{action}" do
          put action, :id => @object.id
          response.should be_unauthenticated
        end
      end
    end
  end

  context "logged in w/o update" do
    before :each do
      login({}, {})
    end

    actions.each do |action|
      if described_class.action_methods.include? action
        it "is unauthorized for: #{action}" do
          put action, :id => @object.id
          response.should be_unauthorized
        end
      end
    end
  end

  context "logged in w/ update" do
    before :each do
      login({}, {:role => 'update_' + @model.table_name.singularize})
    end
    actions.each do |action|
      if described_class.action_methods.include? action
        it "updates for: #{action}" do
          put action, :id => @object.id
          response.should be_success_or_redirect
          assigns(@object.class.table_name.singularize.to_sym).should eq(@object)
        end
      end
    end
  end
end

shared_examples_for "an authorized delete" do
  actions = ['destroy']

  context "not logged in" do
    actions.each do |action|
      it "is unauthorized for: #{action}" do
        delete action, :id => @object.id
        response.should be_unauthenticated
        @object.class.where(:id => @object.id).count.should == 1
      end
    end
  end

  context "logged in w/o superuser" do
    before :each do
      login({}, {})
    end

    actions.each do |action|
      it "is unauthorized for: #{action}" do
        delete action, :id => @object.id
        response.should be_unauthorized
        @object.class.where(:id => @object.id).count.should == 1
      end
    end
  end

  context "logged in w/ superuser" do
    before :each do
      login({}, {:role => 'superuser'})
    end
    actions.each do |action|
      it "updates for: #{action}" do
        get 'delete', :id => @object.id, :format => :json
        response.should be_success_or_redirect
        assigns(@object.class.table_name.singularize.to_sym).should eq(@object)
        #assigns(:model_stats).should_not be_nil
        #assigns(:relationship_stats).should_not be_nil
        @object.class.where(:id => @object.id).count.should == 1

        delete action, :id => @object.id
        response.should be_success_or_redirect
        assigns(@object.class.table_name.singularize.to_sym).should eq(@object)
        @object.class.where(:id => @object.id).count.should == 0
      end
    end
  end
end

shared_examples_for "an authorized action" do |actions, ability|
  context "not logged in" do
    actions.each do |action|
      if described_class.action_methods.include? action
        it "is unauthorized for: #{action}" do
          get action, :id => @object.id
          response.should be_unauthenticated
        end
      end
    end
  end

  context "logged in w/o #{ability}" do
    before :each do
      login({}, {})
    end

    actions.each do |action|
      if described_class.action_methods.include? action
        it "is unauthorized for: #{action}" do
          get action, :id => @object.id
          response.should be_unauthorized
        end
      end
    end
  end

  context "logged in w/ #{ability}" do
    before :each do
      login({}, {:role => ability})
    end
    actions.each do |action|
      if described_class.action_methods.include? action
        it "succeeds for: #{action}" do
          object_id = @object.id
          get action, :id => @object.id
          response.should_not be_unauthorized
        end
      end
    end
  end
end

shared_examples_for "an authorized controller" do
  context "not logged in" do
    if described_class.action_methods.include? 'index'
      it "should fail for index" do
        get 'index'
        response.should be_unauthenticated
      end
    end

    ['show', 'tooltip'].each do |action|
      if described_class.action_methods.include? action
        it "should fail for #{action}" do
          get action, :id => @object.id
          response.should be_unauthenticated
        end
      end
    end
  end

  context "authorized" do
    before :each do
      login({}, { :role => @login_role || 'superuser' })
    end

    if described_class.action_methods.include? 'index'
      describe "GET 'index'" do
        it "returns http success" do
          get 'index'
          response.should be_success_or_redirect
        end
      end
    end

    if described_class.action_methods.include? 'show'
      describe "GET 'show'" do
        it "returns http success" do
          get 'show', :id => @object.id
          response.should be_success_or_redirect
        end
        it "returns the right object" do
          get 'show', :id => @object.id
          assigns(@object.class.table_name.singularize.to_sym).should eq(@object)
        end
      end
    end
  end
end

shared_examples_for "an authorized resource controller" do
  it_behaves_like "an authorized controller"

  context "authorized" do
    before :each do
      login({}, { :role => @login_role || 'superuser' })
    end

    describe "GET 'index'" do
      it "returns the right objects" do
        get 'index'
        assigns(@model.table_name.to_sym).should eq(@index_objs)
      end
    end
  end
end

shared_examples_for "an admin controller" do
  context "non-admin" do
    before :each do
      login({}, {})
    end
    if described_class.action_methods.include? 'index'
      it "fails as non-admin" do
        get 'index'

        response.should be_unauthorized
      end

      if described_class.action_methods.include? 'show'
        it "should fail for show" do
          get 'show', :id => @object.id

        response.should be_unauthorized
        end
      end
    end
  end

  context "admin" do
    before :each do
      login({}, { :role => @login_role || 'superuser' })
    end

    if described_class.action_methods.include? 'index'
      describe "GET 'index'" do
        it "returns http success" do
          get 'index'
          response.should be_success_or_redirect
        end
      end
    end
  end
end
