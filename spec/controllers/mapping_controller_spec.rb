require 'spec_helper'

describe MappingController do

  describe "GET 'show'" do
    it "returns http success" do
      get 'show'
      response.should be_success
    end
  end

  describe "GET 'map_rcontrol'" do
    it "returns http success" do
      get 'map_rcontrol'
      response.should be_success
    end
  end

  describe "GET 'map_ccontrol'" do
    it "returns http success" do
      get 'map_ccontrol'
      response.should be_success
    end
  end

end
