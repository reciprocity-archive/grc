require 'spec_helper'
require 'base_objects'

require 'authored_model'

describe SystemSystem do
  include BaseObjects

  before :each do
    create_base_objects
    @sys1 = FactoryGirl.create(:system, :slug => 'SYS-1')
    @sys2 = FactoryGirl.create(:system, :slug => 'SYS-2')
    @sys3 = FactoryGirl.create(:system, :slug => 'SYS-3')
  end

  it "does not allow a system linking to itself" do
    @ss1 = FactoryGirl.build(:system_system, :parent => @sys1, :child => @sys1)
    @ss1.save.should eq(false)
  end

  it "does not allow cycles" do
    @ss1 = FactoryGirl.create(:system_system, :parent => @sys1, :child => @sys2)
    @ss2 = FactoryGirl.create(:system_system, :parent => @sys2, :child => @sys3)
    @ss3 = FactoryGirl.build( :system_system, :parent => @sys3, :child => @sys1)
    @ss3.save.should eq(false)
  end
end

