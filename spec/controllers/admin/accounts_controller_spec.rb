require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe Admin::AccountsController do
  include BaseObjects

  before :each do
    @account = FactoryGirl.create(:account, :email => 'a@b.com', :role => 'superuser', :password => '1111', :password_confirmation => '1111')

    # For use by authorized_controller tests
    @model = Program
    @object = @account
    @login_role = :superuser
  end

  it_behaves_like "an authorized controller"

  describe "superuser" do
    before :each do
      login({}, { :role => :superuser })
    end

    describe "PUT 'update'" do
      it "updates an existing object" do
        @account.valid_password?("2222").should be_false
        test_controller_update(:account, @account, :password => "2222", :password_confirmation => '2222')
        @account.reload
        @account.valid_password?("2222").should be_true
      end
    end

  end

end
