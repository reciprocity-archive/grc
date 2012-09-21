require 'spec_helper'
require 'base_objects'

describe ApplicationHelper do
  include BaseObjects

  context "shorthand" do
    it "should work" do
      pat(:cancel).should eq("Cancel")
    end
  end

  context "has_feature" do
    it "should work" do
      @_features = { :TEST => 1}
      has_feature?(:TEST).should eq(1)
      has_feature?(:NONEXISTENT).should eq(nil)
    end
  end
end
