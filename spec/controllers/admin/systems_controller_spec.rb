require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe Admin::SystemsController do
  include BaseObjects

  before :each do
    create_base_objects
    @model = System
    @object = @sys
    @index_objs = [@sys]
  end

  it_behaves_like "an authorized resource controller"

  describe "authorized" do
    before :each do
      login({}, { :role => 'superuser' })
    end

    describe "POST 'create'" do
      it "creates a new object" do
        test_controller_create(:system, :title => "sys2", :slug => 'SYS2', :description => "sys 2", :infrastructure => true)
      end
    end

    describe "PUT 'update'" do
      it "updates an existing object" do
        test_controller_update(:system, @sys, :title => "sys1a")
      end
    end
  end

end
