require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe SystemsController do
  include BaseObjects

  context "authorization" do
    before :each do
      create_base_objects

      # For use by authorized_controller tests
      @model = System
      @object = @sys
    end

    it_behaves_like "an authorized create"
    it_behaves_like "an authorized new"
    it_behaves_like "an authorized read", ['tooltip']
    it_behaves_like "an authorized update", ['edit', 'update']
    it_behaves_like "an authorized delete"
  end
end
