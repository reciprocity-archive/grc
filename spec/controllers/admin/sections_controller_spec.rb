require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe Admin::SectionsController do
  include BaseObjects

  before :each do
    create_base_objects

    @model = Section
    @object = @sec
    @index_objs = [@sec]
  end

  it_behaves_like "an admin controller"
  it_behaves_like "an authorized controller"
end
