require 'spec_helper'
require 'authorized_controller'

describe HelpController do
  it "should render the right help document" do
    login({}, {})
    get 'show', :slug => 'directive'
    response.should be_success
  end

  it "should render the xhr response"
end
