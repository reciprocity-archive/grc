require 'spec_helper'

describe AuthorizedModel do
  context 'get abilities' do
    before :each do
      @control = FactoryGirl.create(:control)
      @unauthorized_person = FactoryGirl.create(:person)
      @authorized_person = FactoryGirl.create(:person)
      @child_control = FactoryGirl.create(:control)
      @child_control.implementing_controls << @control
      @authorized_multiple_person = FactoryGirl.create(:person)
      FactoryGirl.create(:object_person, :person => @authorized_person, :personable => @control)
      FactoryGirl.create(:object_person, :person => @authorized_person, :personable => @child_control, :role => 'test')
      FactoryGirl.create(:object_person, :person => @authorized_multiple_person, :personable => @control, :role => 'owner')
      FactoryGirl.create(:object_person, :person => @authorized_person, :personable => @control.program, :role => 'program_role')
    end


    it 'should work with an authorized person' do
      @control.abilities(@authorized_person).should include(:default)
    end

    it "should not return abilities with an unauthorized person" do
      @control.abilities(@unauthorized_person).should eq(Set.new)
    end

    it "should return the ability if the user has a role on a parent" do
      @child_control.abilities(@authorized_person).should include(:default)
    end

    it "should merge all of the abilities if the user has multiple roles from ancestor objects" do
      # Parent control ability
      @child_control.abilities(@authorized_person).should include(:default)

      # Child control ability
      @child_control.abilities(@authorized_person).should include(:test)

      # Parent control program ability
      @child_control.abilities(@authorized_person).should include(:program_role)
    end

    it "should return multiple abilities if the role has multiple abilities" do
      @control.abilities(@authorized_multiple_person).should include(:create)
      @control.abilities(@authorized_multiple_person).should include(:update)
      @control.abilities(@authorized_multiple_person).should include(:delete)
    end
  end

  context "allowed" do
    before :each do
      @superuser = FactoryGirl.create(:account, :email => 'root@t.com', :password => 'root', :password_confirmation => 'root', :role => :superuser)
      @viewer = FactoryGirl.create(:account, :email => 'viewer@t.com', :password => 'viewer', :password_confirmation => 'viewer', :role => :viewer)
      @unauthorized_person = FactoryGirl.create(:person)
      @authorized_person = FactoryGirl.create(:person)

      @control = FactoryGirl.create(:control)
      @child_control = FactoryGirl.create(:control)
      @child_control.implementing_controls << @control
      @authorized_multiple_person = FactoryGirl.create(:person)
      FactoryGirl.create(:object_person, :person => @authorized_person, :personable => @control)
      FactoryGirl.create(:object_person, :person => @authorized_person, :personable => @child_control, :role => :test)
      FactoryGirl.create(:object_person, :person => @authorized_multiple_person, :personable => @control, :role => :superuser)
      FactoryGirl.create(:object_person, :person => @authorized_person, :personable => @control.program, :role => :program_role)
    end

    it "should return true if the user has the ability" do
      @control.allowed?(:default, @authorized_person).should be(true)
      @control.program.allowed?(:program_role, @authorized_person).should be(true)
    end

    it "should return false if the user does not have the ability" do
      @control.allowed?('not_allowed', @authorized_person).should be(false)
    end


    it "should run the block if allowed? passes" do
      bar = 0
      @control.allowed?('foo', @superuser) do
        bar = 1
      end
      bar.should be(1)
    end

    it "should properly set account-level abilities" do
      @control.allowed?('not_allowed', @viewer).should be(false)
      @control.allowed?(:read, @viewer).should be(true)
    end

    it "should always return true if you are the superuser" do
      @control.allowed?('not_allowed', @superuser).should be(true)
    end
  end
end
