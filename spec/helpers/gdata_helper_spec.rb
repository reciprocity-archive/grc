require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the GdataHelper. For example:
#
# describe GdataHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe GdataHelper do
  before :each do
    @doc1 = Gdoc::Document.new("doc1")
    @doc2 = Gdoc::Document.new("doc2")
    @docs = { '1' => @doc1, '2' => @doc2 }
  end

  describe "utility" do
    it "gdocs_by_title" do
      helper.gdocs_by_title(@docs).should == { 'doc1' => @doc1, 'doc2' => @doc2 }
    end
  end

  describe "client" do
    before :each do
      @client = Gdoc::Client.new
      helper.stub(:new_client).and_return(@client)
    end

    it "redirects when receiving token in url" do
      params[:token] = '123'
      @client.should_receive(:set_token).with('123', true).and_return('456')
      helper.should_receive(:redirect_to).with('http://test.host')
      helper.get_gdata_client.should be_nil
    end

    it "redirects to gdocs if no auth" do
      @client.should_receive(:authsub).with('http://test.host').and_return('http://other.host')
      helper.should_receive(:redirect_to).with('http://other.host')
      helper.get_gdata_client.should be_nil
    end

    it "redirects to gdocs with ajax if no auth" do
      @client.should_receive(:authsub).with('http://test.host/1').and_return('http://other.host')
      #assigns(:redirect_url).should eq('http://other.host')
      helper.should_receive(:render).with(:partial => 'base/ajax_redirect')
      helper.get_gdata_client(:ajax => true, :retry_url => 'http://test.host/1').should be_nil
    end

    it "sets token in client" do
      session[:gtoken] = '123'
      @client.should_receive(:set_token).with('123')
      helper.get_gdata_client.should eq(@client)
    end
  end

  describe "caching" do
    before :each do
      @client = Gdoc::Client.new
      helper.stub(:get_gdata_client).and_return(@client)
    end

    it "returns from cache" do
      session[:x] = {}
      session[:x][:f1] = @docs
      helper.get_gdata(:x, :folder => :f1).should eq(@docs)
    end

    it "gets from client" do
      session[:x] = {}
      helper.should_receive(:get_gdata_client).and_return(@client)
      helper.get_gdata(:x, :folder => :f1) do |client|
        client.should eq(@client)
        @docs
      end
      session[:x][:f1].should eq(@docs)
    end

    it "gets from client on refresh" do
      session[:x] = {}
      session[:x][:f1] = @docs
      helper.should_receive(:get_gdata_client).and_return(@client)
      helper.get_gdata(:x, :folder => :f1, :refresh => true) do |client|
        client.should eq(@client)
        @docs
      end
      session[:x][:f1].should eq(@docs)
    end
  end
end
