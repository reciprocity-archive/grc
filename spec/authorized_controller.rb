# Test some of the authorization basics for resource controllers.

# FIXME: Should (based on parameters) automatically test
# multiple login roles.

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
          get 'show', :id => @show_obj.id

        response.should be_unauthorized
        end
      end
    end
  end

  context "admin" do
    before :each do
      login({}, { :role => @login_role || 'admin' })
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

shared_examples_for "an authorized read" do |actions|
  actions.each do |action|
    if described_class.action_methods.include? action
      context "not logged in" do
        it "should fail for #{action}" do
          get action, :id => @show_obj.id
          response.should be_unauthenticated
        end
      end

      context "logged in w/o read" do
        before :each do
          login({}, {})
        end
        it "should be unauthorized for #{action}" do
          get action, :id => @show_obj.id
          response.should be_unauthorized
        end
      end

      context "logged in with read" do
        before :each do
          login({}, {:role => :read})
        end

        it "should be authorized w/ read for #{action}" do
          get action, :id => @show_obj.id
          response.should be_success_or_redirect
          assigns(@show_obj.class.table_name.singularize.to_sym).should eq(@show_obj)
        end
      end
    end
  end
end

shared_examples_for "an authorized update" do |actions|
  actions.each do |action|
    if described_class.action_methods.include? action
      context "not logged in" do
        it "is unauthorized for #{action}" do
          get action, :id => @show_obj.id
          response.should be_unauthenticated
        end
      end

      context "logged in w/o update" do
        before :each do
          login({}, {})
        end
        it "is unauthorized for #{action}" do
          get action, :id => @show_obj.id
          response.should be_unauthorized
        end
      end

      context "logged in w/ update" do
        before :each do
          login({}, {:role => :update})
        end

        it "updates for #{action}" do
          put action, :id => @show_obj.id
          response.should be_success_or_redirect
          assigns(@show_obj.class.table_name.singularize.to_sym).should eq(@show_obj)
        end
      end
    end
  end
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
      login({}, {:role => :create})
    end

    it "not unauthorized" do
      post 'create'
      # Note: The operation may still fail, just not due to
      # an authorization issue.
      response.should_not be_unauthorized
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
      login({}, {:role => :create})
    end

    it "not unauthorized" do
      get 'new'
      # Note: The operation may still fail, just not due to
      # an authorization issue.
      response.should_not be_unauthorized
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
          get action, :id => @show_obj.id
          response.should be_unauthenticated
        end
      end
    end
  end

  context "authorized" do
    before :each do
      login({}, { :role => @login_role || 'admin' })
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
          get 'show', :id => @show_obj.id
          response.should be_success_or_redirect
        end
        it "returns the right object" do
          get 'show', :id => @show_obj.id
          assigns(@show_obj.class.table_name.singularize.to_sym).should eq(@show_obj)
        end
      end
    end
  end
end

shared_examples_for "an authorized resource controller" do
  it_behaves_like "an authorized controller"

  context "authorized" do
    before :each do
      login({}, { :role => @login_role || 'admin' })
    end

    describe "GET 'index'" do
      it "returns the right objects" do
        get 'index'
        assigns(@model.table_name.to_sym).should eq(@index_objs)
      end
    end
  end
end
