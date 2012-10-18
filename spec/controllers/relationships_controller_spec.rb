require 'spec_helper'
require 'authorized_controller'

describe RelationshipsController do
  before :each do
    @model = Relationship

    # Create a set of relationships to test
  end

  context "authorization" do
    #it_behaves_like "an authorized index"
    #it_behaves_like "an authorized create"
    #it_behaves_like "an authorized new"
    #it_behaves_like "an authorized update", ['edit', 'update']
    #it_behaves_like "an authorized delete"
    #it_behaves_like "an authorized action", ['list'], 'read_person'
    #it_behaves_like "an authorized action", ['list_update', 'list_edit'], 'update_person'
  end

  context "index" do
    it "should return all relationships"
    it "should return relationships with the specified relationship_type"
    it "should return relationships with the specified source type"
    it "should return relationships with the specified source type and id"
    it "should return relationships with the specified destination type"
    it "should return relationships with the specified destination type and id"
    it "should return relationships with the specified object type on either side"
    it "should return relationships with the specified object type and id on either side"
    it "should return relationships with the specified object type on either side and other type on other side"
    it "should return relationships with the specified object type on either side and other type and id on other side"
  end

end
