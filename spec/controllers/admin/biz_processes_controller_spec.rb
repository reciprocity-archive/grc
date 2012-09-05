require 'spec_helper'
require 'base_objects'

describe Admin::BizProcessesController do
  include BaseObjects

  describe "GET 'index' without authorization" do
    it "fails as guest" do
      test_unauth
    end
  end

  describe "authorized" do
    before :each do
      login({}, { :role => 'superuser' })
      create_base_objects
    end

    describe "GET 'index'" do
      it "returns http success" do
        test_controller_index(:biz_processes, [@bp])
      end
    end

    describe "POST 'create'" do
      it "creates a new object" do
        test_controller_create(:biz_process, :description => "desc2", :slug => 'BP2', :title => 'BP2')
      end
    end

    describe "PUT 'update'" do
      it "updates an existing object" do
        test_controller_update(:biz_process, @bp, :description => "desc2")
      end
    end

  end

end
