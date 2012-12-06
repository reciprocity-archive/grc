require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe ProgramsController do
  include BaseObjects

  before :each do
    create_base_objects

    # For use by authorized_controller tests
    @model = Program
    @object = @reg
  end

  context "authorization" do
    it_behaves_like "an authorized create"
    it_behaves_like "an authorized new"
    it_behaves_like "an authorized read", ['show',
                                           'tooltip',
                                           'controls',
                                           'sections',
                                           'section_controls',
                                           'control_sections',
                                           'category_controls']
    it_behaves_like "an authorized update", ['edit', 'update']
    it_behaves_like "an authorized delete"
    it_behaves_like "an authorized action", ['import'], 'update_program'
  end

  context "show" do
    before :each do
      login({}, { :role => 'superuser' })
      @ctl2 = FactoryGirl.create(:control, :title => 'Control 2', :slug => 'CTL2', :description => 'x', :program => @creg)
      @ctl3 = FactoryGirl.create(:control, :title => 'Control 3', :slug => 'CTL2-1', :description => 'x', :parent => @ctl2, :program => @creg)
      @person = FactoryGirl.create(:person)
      @ctl3.object_people.create({:person => @person, :role => 'executive'}, :without_protection => true)
      @sec2 = FactoryGirl.create(:section, :title => 'Section 2', :slug => 'REG1-SEC2', :description => 'x', :program => @reg)
      @sec3 = FactoryGirl.create(:section, :title => 'Section 3', :slug => 'REG1-SEC3', :description => 'x', :program => @reg)
      @sec2.controls << @ctl
      @sec2.save
      @sec3.controls << @ctl2
      @sec3.controls << @ctl3
      @sec3.save
    end

    it "gets the correct stats" do
      pending "@stats not actually used except in tests"
      get 'show', :id => @reg.id
      stats = assigns(:stats)
      stats[:sections_count].should eq(3)
      stats[:sections_done_count].should eq(2)
      stats[:sections_undone_count].should eq(1)
      stats[:sections_na_count].should eq(0)
      stats[:controls_count].should eq(3)
      stats[:controls_parented_count].should eq(1)
    end
  end

  context "update" do
    it "should properly validate and update the program"
  end

  context "export" do
    before :each do
      login({}, { :role => 'superuser' })
    end
    it "should export" do
      @reg.audit_duration = Option.create(:title => "1 Week", :role => 'audit_duration')
      @reg.audit_frequency = Option.create(:title => "Often", :role => 'audit_frequency')
      @reg.save
      get 'export', :id => @reg.id, :format => :csv
      # program titles, 1 program, 2 blank lines, section titles, 1 section
      response.body.split("\n").size.should == 6
      (response.body =~ /1 Week/).should_not be_nil
      (response.body =~ /Often/).should_not be_nil
    end
  end

  context "import program/sections" do
    before :each do
      login({}, { :role => 'superuser' })
    end

    it "should prepare import" do
      Option.create(:title => "1 Fortnight", :role => 'audit_duration')
      Option.create(:title => "Soonish", :role => 'audit_frequency')
      post 'import', :id => @reg.id, :upload => fixture_file_upload("/REG1.csv")
      assigns(:messages).should == [
        "Invalid program heading Bogus1",
        "Invalid section heading Bogus2"
      ]
      assigns(:errors).should include 2
      assigns(:errors)[2].should include :title
      assigns(:errors)[2][:title].should == ["needs a value"]
      assigns(:creates).should == [ "REG1-SEC2", "REG1-SEC3-BAD" ]
      assigns(:updates).should == [ "REG1-SEC1"]
    end

    it "should prepare import with missing option" do
      post 'import', :id => @reg.id, :upload => fixture_file_upload("/REG1.csv")
      assigns(:messages).should == [
        "Invalid program heading Bogus1",
        "Invalid section heading Bogus2"
      ]
      assigns(:errors).should include 2
      assigns(:errors)[2].should include :title
      assigns(:errors)[2][:title].should == ["needs a value"]
      assigns(:creates).should == [ "REG1-SEC2", "REG1-SEC3-BAD" ]
      assigns(:updates).should == [ "REG1-SEC1"]
    end

    it "should do import" do
      post 'import', :id => @reg.id, :upload => fixture_file_upload("/REG1.csv"), :confirm => "true"
      Section.find_by_slug("REG1-SEC1").description.should == "new description x"
    end
  end

  context "import controls" do
    before :each do
      login({}, { :role => 'superuser' })
      @sys5 = FactoryGirl.create(:system, :title => 'System 1', :slug => 'SYS5', :description => 'x')
    end

    it "should do import" do
      post 'import_controls', :id => @reg.id, :upload => fixture_file_upload("/CONTROLS.csv"), :confirm => "true"
      ctl = Control.find_by_slug("CTL1")
      ctl.description.should == "This is Control 1"
      ctl.documents.should == [Document.find_by_link('file://file/xyz')]
      ctl.object_people.size.should == 1
      op = ctl.object_people.first
      op.role.should == 'operator'
      op.person.email.should == 'a@b.com'
      Control.find_by_slug('CTL2').categories.map {|x| x.name}.should == ['cat1']
      Control.find_by_slug('CTL2').systems.should == [System.find_by_slug('SYS2'), @sys5]
    end
  end

  context "export controls" do
    before :each do
      login({}, { :role => 'superuser' })
      @ctl2 = FactoryGirl.create(:control, :title => 'Control 2', :slug => 'CTL2', :description => 'x', :program => @creg)
      @ctl3 = FactoryGirl.create(:control, :title => 'Control 3', :slug => 'CTL2-1', :description => 'x', :parent => @ctl2, :program => @creg)
      @person = FactoryGirl.create(:person)
      @ctl3.object_people.create({:person => @person, :role => 'executive'}, :without_protection => true)
    end
    it "should export" do
      get 'export_controls', :id => @creg.id, :format => :csv
      # system titles, system data
      response.body.split("\n").size.should == 7
    end
  end

  context "non-CRUD" do
    before :each do
      login({}, {:role => 'superuser'})
    end

    context "sections" do
      it "should show the right associated sections"
      it "should search properly"
    end

    context "controls" do
      it "should show the right associated sections"
      it "should search properly"
    end


    context "category_controls" do
      it "should display the right categories"
    end

    context "section_controls" do
      it "should do some tests"
    end

    context "control_sections" do
      it "should show the right sections"
    end
  end
end
