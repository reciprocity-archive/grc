require 'spec_helper'

describe Directive do
  context "relationships" do
    before :each do
      @product = FactoryGirl.create(:product)
      @directive = FactoryGirl.create(:directive)
    end
  end
end
