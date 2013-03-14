require 'spec_helper'
require 'authorized_controller'

describe DocumentController do
  before :each do
    @model = Document
    @prog = FactoryGirl.create(:program, :title => 'Reg 1', :slug => 'reg1')
    @cycle = FactoryGirl.create(:cycle, :program => @prog, :start_at => '2012-01-01')
    session[:cycle_id] = @cycle.id
    @object = @prog # FIXME: Necessary for authorized action test to work
  end

  context "authorization" do
    it_behaves_like "an authorized index"
    it_behaves_like "an authorized action", ['sync'], :update_document
  end

  context "gdata" do
    before :each do
      login({}, { :role => 'superuser' })

      @cms_folder = Gdoc::Document.new('CMS')
      @cycle_folder = Gdoc::Document.new('REG1-2012-01-01', :parent => @cms_folder)
      @systems_folder = Gdoc::Document.new('Systems', :parent => @cycle_folder)

      session[:gtoken] = 'gtoken1'
      controller.stub(:get_gfolders) do
        []
      end
      controller.stub(:gdocs_by_title) do |folders|
        {
          'CMS' => @cms_folder,
          'CMS/REG1-2012-01-01' => @cycle_folder,
          'CMS/REG1-2012-01-01/Systems' => @systems_folder,
          'CMS/REG1-2012-01-01/Accepted' => Gdoc::Document.new('Accepted', :parent => @cms_folder),
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
      FactoryGirl.create(:system, :title => 'System 1', :slug => 'sys1', :description => 'x', :infrastructure => true)
      @gdoc_client.should_receive(:create_folder).at_least(:once).with('SYS1', :parent => @systems_folder).and_return(Gdoc::Document.new('sys1', :parent => @systems_folder))
      get 'sync'
      response.should be_success
      assert_template :template => 'document/sync'
      assigns(:messages).should eq(["Created CMS/REG1-2012-01-01/Systems/sys1"])
    end

    it "creates base folders" do
      controller.stub(:gdocs_by_title) do |folders|
        {
          'CMS' => @cms_folder,
        }
      end
      FactoryGirl.create(:system, :title => 'System 1', :slug => 'sys1', :description => 'x', :infrastructure => true)
      @gdoc_client.should_receive(:create_folder).at_least(:once).with('REG1-2012-01-01', :parent => @cms_folder).and_return(@cycle_folder)
      @gdoc_client.should_receive(:create_folder).at_least(:once).with('Systems', :parent => @cycle_folder).and_return(@systems_folder)
      @gdoc_client.should_receive(:create_folder).at_least(:once).with('Accepted', :parent => @cycle_folder).and_return(Gdoc::Document.new('Accepted', :parent => @cms_folder))
      @gdoc_client.should_receive(:create_folder).at_least(:once).with('SYS1', :parent => @systems_folder).and_return(Gdoc::Document.new('sys1', :parent => @systems_folder))
      get 'sync'
      response.should be_success
      assert_template :template => 'document/sync'
      assigns(:messages).length.should eq(4)
    end
  end

end
