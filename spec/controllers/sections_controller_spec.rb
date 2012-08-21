require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe SectionsController do
  include BaseObjects

  context "authorization" do
    before :each do
      create_base_objects

      # For use by authorized_controller tests
      @model = Section
      @object = @sec
    end

    it_behaves_like "an authorized create"
    it_behaves_like "an authorized new"
    it_behaves_like "an authorized read", ['tooltip']
    it_behaves_like "an authorized update", ['edit', 'update']
  end
end