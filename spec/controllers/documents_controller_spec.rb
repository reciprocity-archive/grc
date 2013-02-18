require 'spec_helper'
require 'authorized_controller'

describe DocumentsController do
  before :each do
    @model = Document
    @object = FactoryGirl.create(:document, :title => 'Test')
    @directive = FactoryGirl.create(:directive)
    @index_objs = [@object]
  end

  context "authorization" do
    it_behaves_like "an authorized index"
    it_behaves_like "an authorized create"
    it_behaves_like "an authorized new"
    #it_behaves_like "an authorized read", ['show']
    it_behaves_like "an authorized update", ['edit', 'update']
    it_behaves_like "an authorized delete"
  end
end
