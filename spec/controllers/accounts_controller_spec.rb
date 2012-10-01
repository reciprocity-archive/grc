require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe AccountsController do
  before :each do
    @model = Account
    @object = FactoryGirl.create(:account)
  end

  it_behaves_like "an authorized update", ['edit', 'update']
  it_behaves_like "an authorized delete"
  it_behaves_like "an authorized create"
  it_behaves_like "an authorized new"
end
