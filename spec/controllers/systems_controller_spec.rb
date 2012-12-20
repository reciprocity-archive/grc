require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe SystemsController do
  include BaseObjects

  before :each do
    create_base_objects

    # For use by authorized_controller tests
    @model = System
    @object = @sys
  end

  context "authorization" do
    it_behaves_like "an authorized create", ['import']
    it_behaves_like "an authorized new"
    it_behaves_like "an authorized read", ['tooltip']
    it_behaves_like "an authorized update", ['edit', 'update']
    it_behaves_like "an authorized delete"
  end

  context "export" do
    before :each do
      login({}, { :role => 'superuser' })
    end
    it "should export" do
      get 'export', :id => @sys.id, :format => :csv
      # system titles, system data
      response.body.split("\n").size.should == 6
    end
  end

  context "import" do
    before :each do
      login({}, { :role => 'superuser' })
    end

    it "should prepare import" do
      post 'import', :upload => fixture_file_upload("/SYS.csv")
      assigns(:messages).should == []
      assigns(:creates).should == [ 'SYS2', 'SYS3' ]
      assigns(:updates).should == [ 'SYS1' ]
      assigns(:errors).should == {}
      System.find_by_slug('SYS2').should be_nil
      doc = Document.find_by_link('http://www.site.com/')
      doc.title.should == 'A Title'
      doc.description.should == 'a description '
      doc2 = Document.find_by_link('http://www.site2.com/')
      System.find_by_slug('SYS1').documents.should == [doc, doc2]
    end

    it "should do import" do
      post 'import', :upload => fixture_file_upload("/SYS.csv"), :confirm => true
      assigns(:messages).should == []
      assigns(:creates).should == [ 'SYS2', 'SYS3' ]
      assigns(:updates).should == [ 'SYS1' ]
      assigns(:errors).should == {}
      sys1 = System.find_by_slug('SYS1')
      sys1.title.should == 'System 1'
      sys1.infrastructure.should be_true
      sys2 = System.find_by_slug('SYS2')
      sys1.object_people.size.should == 0
      sys2.object_people.size.should == 1
      sys2.object_people[0].role.should == 'accountable'
      sys2.object_people[0].person.email.should == 'b@t.com'
      rels = Relationship.where(:source_id => sys2, :source_type => System.name)
      rels.size.should == 1
      rels[0].destination.slug.should == 'ORG1'
      rels[0].destination.class.should == OrgGroup
      sys1.categories.should == [Category.find_by_name('cat1')]
      sys2.infrastructure.should be_false
      sys2.description.should == "This is System 2\n---\nnote 1\n---\nnote 2"
      sys2.sub_systems.map {|x| x.slug}.sort.should == %w(SYS1 SYSX)

      post 'import', :upload => fixture_file_upload("/SYS.csv"), :confirm => true
      sys2.reload
      sys2.object_people.size.should == 1
      sys2.object_people[0].role.should == 'accountable'
      sys2.object_people[0].person.email.should == 'b@t.com'
    end
  end
end
