require 'spec_helper'

describe DocumentController do
  describe "GET 'index' without authorization" do
    it "fails as guest" do
      login({}, {})
      get 'index'
      response.should be_redirect
    end
  end

  context "authorized" do
    before :each do
      login({}, { :role => 'admin' })
    end

    describe "GET 'index'" do
      it "returns http success" do
        get 'index'
        response.should be_success
      end
    end
  end

  context "gdata" do
    before :each do
      login({}, { :role => 'admin' })
      clear_db

      @cms = Gdoc::Document.new('CMS')
      @systems = Gdoc::Document.new('Systems', :parent => @cms)

      session[:gtoken] = 'gtoken1'
      controller.stub(:get_gfolders) do
        []
      end
      controller.stub(:gdocs_by_title) do |folders|
        {
          'CMS' => @cms,
          'CMS/Systems' => @systems,
          'CMS/Accepted' => Gdoc::Document.new('Accepted', :parent => @cms),
        }
      end

      @gdoc_client = double('Gdoc::Client')

      controller.stub(:get_gdata_client) do
        @gdoc_client
      end
    end

    it "syncs with no systems" do
      get 'sync'
      response.should be_success
      assert_template :template => 'document/sync'
    end

    it "syncs new system" do
      System.create(:title => 'System 1', :slug => 'sys1', :description => 'x', :infrastructure => true)
      @gdoc_client.should_receive(:create_folder).at_least(:once).with('SYS1', :parent => @systems).and_return(Gdoc::Document.new('sys1', :parent => @systems))
      get 'sync'
      response.should be_success
      assert_template :template => 'document/sync'
      assigns(:messages).should eq(["Created CMS/Systems/sys1"])
    end

    it "creates base folders" do
      controller.stub(:gdocs_by_title) do |folders|
        {
          'CMS' => @cms,
        }
      end
      System.create(:title => 'System 1', :slug => 'sys1', :description => 'x', :infrastructure => true)
      @gdoc_client.should_receive(:create_folder).at_least(:once).with('Systems', :parent => @cms).and_return(@systems)
      @gdoc_client.should_receive(:create_folder).at_least(:once).with('Accepted', :parent => @cms).and_return(Gdoc::Document.new('Accepted', :parent => @cms))
      @gdoc_client.should_receive(:create_folder).at_least(:once).with('SYS1', :parent => @systems).and_return(Gdoc::Document.new('sys1', :parent => @systems))
      get 'sync'
      response.should be_success
      assert_template :template => 'document/sync'
      assigns(:messages).length.should eq(3)
    end
  end

end
