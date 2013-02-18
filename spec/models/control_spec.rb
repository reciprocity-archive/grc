require 'spec_helper'
require 'base_objects'

# Force reloads
require 'authored_model'
ActiveSupport::Dependencies.explicitly_unloadable_constants << 'AuthoredModel'

describe Control do
  include BaseObjects

  before :each do
    create_base_objects
    @account = FactoryGirl.create(:account, :email => "a@b.org", :password => "xxxx", :password_confirmation => "xxxx", :role => "admin")
    @ctl2 = FactoryGirl.create(:control, :title => 'Control 2', :slug => 'REG1-CTL2', :description => 'x', :directive => @reg)
    @opt_verify_freq1 = FactoryGirl.create(:option, :role => 'verify_frequency', :title => 'Frequency 1')
    @opt_verify_freq2 = FactoryGirl.create(:option, :role => 'verify_frequency', :title => 'Frequency 2')
  end

  it "was not modified by anybody in particular" do
    @ctl.modified_by.should eq(nil)
    @ctl.verify_frequency.should eq(nil)
  end

  it "is creates versions when modified by someone" do
    @ctl.authored_update(@account, :verify_frequency => @opt_verify_freq1)
    @ctl.reload
    @ctl.verify_frequency_id.should eq(@opt_verify_freq1.id)
    @ctl.modified_by.should eq(@account)
    @ctl.versions.size.should eq(1)
    @ctl.versions[0].reify.modified_by_id.should eq(nil)

    @ctl.authored_update(@account, :verify_frequency => @opt_verify_freq2)
    @ctl.reload
    @ctl.verify_frequency_id.should eq(@opt_verify_freq2.id)
    @ctl.modified_by.should eq(@account)
    @ctl.versions.size.should eq(2)
    @ctl.versions[1].reify.modified_by_id.should eq(@account.id)
    @ctl.versions[1].reify.verify_frequency_id.should eq(@opt_verify_freq1.id)
    @ctl.versions[0].reify.modified_by_id.should eq(nil)
    @ctl.versions[0].reify.verify_frequency_id.should eq(nil)
  end

  it "creates a version when deleted" do
    pending
    @ctl2.authored_destroy(@account)
    Version.where(:item_type => "Control", :item_id => @ctl2.id).size.should eq(2)
    Version.where(:item_type => "Control", :item_id => @ctl2.id)[0].reify.modified_by_id.should eq(nil)
    Version.where(:item_type => "Control", :item_id => @ctl2.id)[1].reify.modified_by_id.should eq(@account.id)
    Version.where(:item_type => "Control", :item_id => @ctl2.id)[0].reify.is_destroyed.should be_false
    Version.where(:item_type => "Control", :item_id => @ctl2.id)[1].reify.is_destroyed.should be_true
  end

  it "versions relationships" do
    pending
    @ctl.authored_update(@account, :evidence_descriptor_ids => [@desc.id])
    @ctl.save
    @ctl.reload
    # A useless version without author is created (FIXME)
    Version.where(:item_type => "ControlDocumentDescriptor").size.should eq(1)

    @ctl.authored_update(@account, :evidence_descriptor_ids => [])
    @ctl.reload

    # Two versions - one with pre-destroy values, and one with timestamps set
    Version.where(:item_type => "ControlDocumentDescriptor").size.should eq(3)
    #ControlDocumentDescriptor::Version.all.size.should eq(3)
    Version.where(:item_type => "ControlDocumentDescriptor").first.modified_by_id.should eq(nil)
    Version.where(:item_type => "ControlDocumentDescriptor").last.modified_by_id.should eq(@account.id)
    ControlDocumentDescriptor.all.size.should eq(0)
    @ctl.authored_update(@account, :evidence_descriptor_ids => [@desc.id])
    @ctl.reload

    # A useless version without author is created (FIXME)
    ControlDocumentDescriptor::Version.all.size.should eq(4)
    @ctl.control_document_descriptors.size.should eq(1)
    @ctl.control_document_descriptors.first.evidence_descriptor.should eq(@desc)
  end

  it "gets the parent persons" do
    # Get all of the parent persons from all of the sections/directives
    directive = FactoryGirl.create(:directive, :with_people)
    directive.people.count.should eq(3)
    pending
  end

  it "gets the proper persons that own the control" do
    pending
    parent_control = FactoryGirl.create(:control_with_child_controls, child_depth: 2)
  end
end
