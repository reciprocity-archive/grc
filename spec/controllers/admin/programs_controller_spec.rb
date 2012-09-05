require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe Admin::ProgramsController do
  include BaseObjects

  before :each do
    create_base_objects
    @model = Program
    @index_objs = [@creg, @reg]
  end

  it_behaves_like "an admin controller"
  it_behaves_like "an authorized controller"

  describe "authorized" do
    before :each do
      login({}, { :role => 'superuser' })
    end

    #describe "GET 'index'" do
    #  it "returns http success" do
    #    get 'index'
    #    response.should be_success
    #    assigns(:programs).should eq([@creg, @reg])
    #  end
    #end

    describe "POST 'create'" do
      it "creates a new object" do
        test_controller_create(:program, :title => "reg2", :slug => 'REG2')
      end
    end

    describe "PUT 'update'" do
      pending "updates an existing object" do
        test_controller_update(:program, @reg, :title => "reg1a")
      end
    end
  end

end
