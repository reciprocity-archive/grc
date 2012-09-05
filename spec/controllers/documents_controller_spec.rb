require 'spec_helper'
require 'authorized_controller'

describe DocumentsController do
  before :each do
    @model = Document
    @object = FactoryGirl.create(:document, :title => 'Test')
    @program = FactoryGirl.create(:program)
    @index_objs = [@object]
  end

  context "authorization" do
    it_behaves_like "an authorized create"
    it_behaves_like "an authorized new"
    it_behaves_like "an authorized read", ['show']
    it_behaves_like "an authorized update", ['edit', 'update']
    it_behaves_like "an authorized delete"

    it_behaves_like "an authorized action", ['list'], 'read_document'
    it_behaves_like "an authorized action", ['list_update', 'list_edit'], 'update_document'
  end

  context "list" do
    it "should properly search"
  end

  context "list_edit" do
    it "should show the right objects" do
      login({}, {:role => :admin})
      get 'list_edit', {
        :object_type => 'program',
        :object_id => @program.id,
      }
      response.should be_success
    end
  end

  context "list_update" do
    it "should properly add new documents"
  end
end
