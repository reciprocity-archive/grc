require 'spec_helper'
require 'authorized_controller'

describe ObjectDocumentsController do
  before :each do
    @model = ObjectDocument
    @object = FactoryGirl.create(:object_document)
    @document = FactoryGirl.create(:document, :title => 'Test')
    @program = FactoryGirl.create(:program)
    @create_params = {
      :documentable_type => @program.class.name,
      :documentable_id => @program.id,
      :document_id => @document.id
    }
    @index_objs = [@object]
  end

  context "authorization" do
    it_behaves_like "an authorized index"
    it_behaves_like "an authorized create"
    #it_behaves_like "an authorized action", ['list_edit'], 'update_object_document'
  end

  context "list_edit" do
    it "should show the right objects" do
      login({}, {:role => :superuser})
      get 'list_edit', {
        :object_type => @program.class.name,
        :object_id => @program.id,
      }
      response.should be_success
    end
  end

  context "create" do
    it "should properly add new documents" do
      login({}, {:role => :superuser})
      post 'create', {
        :items => { :new_id => {
          :documentable_type => @program.class.name,
          :documentable_id => @program.id,
          :document_id => @document.id
        }}
      }
      response.should be_success
      @program.documents.should include @document
    end
  end
end
