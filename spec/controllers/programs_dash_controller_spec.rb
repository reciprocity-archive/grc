require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe ProgramsDashController do
  include BaseObjects

  before :each do
    Account.create({:email => 'owner1@t.com', :password => 'owner1', :password_confirmation => 'owner1', :role => :owner}, :without_protection => true)
    Account.create({:email => 'owner2@t.com', :password => 'owner2', :password_confirmation => 'owner2', :role => :owner}, :without_protection => true)
    prog = Program.create(:title => 'Reg 1', :slug => 'REG1')

    (2..10).each do |ind|
      Program.create(:title => "Reg #{ind}", :slug => "REG#{ind}")
    end

    # Set up program owners
    @o1 = Account.find_by_email('owner1@t.com')
    @p1 = Program.find_by_slug('REG1')
    ObjectPerson.create(:person => @o1.person, :personable => @p1, :role => 'owner')

    @o2 = Account.find_by_email('owner2@t.com')
    @p2 = Program.find_by_slug('REG2')
    ObjectPerson.create(:person => @o2.person, :personable => @p2, :role => 'owner')
  end

  it_behaves_like "an authorized controller"


  context "owner" do
    it "shows the right programs" do
      @current_user = @o1
      login({}, {})

      get 'index'
      response.should be_success
      assigns(:programs).should eq([@p1])
    end

    it "shows all programs for superuser" do
      login({}, {:role => 'superuser'})
      get 'index'
      response.should be_success
      @all_programs = Program.all
      assigns(:programs).should eq(@all_programs)
    end
  end
end
