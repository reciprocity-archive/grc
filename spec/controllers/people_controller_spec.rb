require 'spec_helper'
require 'authorized_controller'

describe PeopleController do
  before :each do
    @model = Person
    @object = FactoryGirl.create(:person)
    @directive = FactoryGirl.create(:directive)
    @index_objs = [@object]
  end

  context "authorization" do
    it_behaves_like "an authorized index"
    it_behaves_like "an authorized create"
    it_behaves_like "an authorized new"
    it_behaves_like "an authorized update", ['edit', 'update']
    it_behaves_like "an authorized delete"
  end
end
