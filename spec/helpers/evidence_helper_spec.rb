require 'spec_helper'
require 'prawn_monkeypatch'

describe EvidenceHelper do
  before :each do
    @sys = System.create(:title => 'System 1', :slug => 'sys1', :description => 'x', :infrastructure => true)
    @client = double(Gdoc::Client)
    @doc = Gdoc::Document.new("doc1")
    Tempfile.open('test', Rails.root.join('tmp').to_s) do |water|
      Prawn::Document.generate(water.path) do
        start_new_page
        text "Test document"
      end
      water.seek(0)
      @body = water.read
    end
    @user = double(Account)
    @user.stub(:name).and_return("John Doe")
    helper.stub(:current_user).and_return(@user)
  end

  it "watermarks evidence" do
    helper.should_receive(:get_gdata_client).and_return(@client)
    @client.should_receive(:download).with(@doc, 'pdf').and_return(@body)
    @client.stub(:upload) do |title, path|
      title.should eq("Evidence - doc1")
      File.exist?(path).should be_true
      true
    end
    helper.capture_evidence(@doc, @sys).should eq(true)
  end
end
