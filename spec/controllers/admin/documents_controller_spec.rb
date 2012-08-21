require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe Admin::DocumentsController do
  include BaseObjects

  before :each do
    create_base_objects
    @model = Document
    @object = @doc
    @index_objs = [@doc]
  end

  it_behaves_like "an authorized controller"
end
