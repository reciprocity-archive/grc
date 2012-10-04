require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe ProductsController do
  include BaseObjects

  before :each do
    create_base_objects

    # For use by authorized_controller tests
    @model = Product
    @object = FactoryGirl.create(:product)
  end

  context "authorization" do
    it_behaves_like "an authorized create"
    it_behaves_like "an authorized new"
    it_behaves_like "an authorized read", ['show',
                                           'tooltip']
    it_behaves_like "an authorized update", ['edit', 'update']
    it_behaves_like "an authorized action", [], 'update_product'
    it_behaves_like "an authorized delete"
  end

  context "update" do
    it "should properly validate and update the product"
  end
end
