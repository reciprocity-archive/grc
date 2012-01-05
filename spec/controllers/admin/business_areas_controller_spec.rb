require 'spec_helper'
require 'base_objects'

describe Admin::BusinessAreasController do
  include BaseObjects

  describe "GET 'index' without authorization" do
    it "fails as guest" do
      test_unauth
    end
  end

  describe "authorized" do
    before :each do
      login({}, { :role => 'admin' })
      create_base_objects
    end

    describe "GET 'index'" do
      it "returns http success" do
        test_controller_index(:business_areas, [@biz_area])
      end
    end

    describe "POST 'create'" do
      it "creates a new object" do
        test_controller_create(:business_area, :title => "desc2")
      end
    end

    describe "PUT 'update'" do
      it "updates an existing object" do
        test_controller_update(:business_area, @biz_area, :title => "desc2")
      end
    end

  end

end
