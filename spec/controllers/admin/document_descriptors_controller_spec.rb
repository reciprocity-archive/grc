require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe Admin::DocumentDescriptorsController do
  include BaseObjects

  before :each do
    create_base_objects

    @show_obj = @desc
    @index_objs = [@desc]
  end

  it_behaves_like "an admin controller"
  it_behaves_like "an authorized controller"
end
