require 'spec_helper'
require 'base_objects'

describe FormHelper do
  include BaseObjects

  # See http://injecting.by2.be/blog/2010/06/rails3_rspec2_haml.html
  # needed for using HAML helpers
  include Haml::Helpers
  include ActionView::Helpers

  # Needed for form_for
  def polymorphic_path(args, options)
    "http://fake.com/"
  end

  context "error_messages_inline" do
    it "renders properly" do
      init_haml_helpers
      create_base_objects
      form_for(@reg) do |f|
        f.object.errors[:foo] = 'This is a problem'

        message = error_messages_inline(f, :foo)
        message.should have_selector("span")
        message.should have_selector("span span")
        message.should have_content("This is a problem")
      end
    end
  end

  context "member errors" do
    before :each do
      init_haml_helpers
      create_base_objects
    end

    it "displays all errors" do
      form_for(@reg) do |f|
        f.object.errors[:foo] = 'This is a problem'

        message = member_error_messages_inline(f.object)
        message.should have_selector("span.help-inline")
        message.should have_selector("span.help-inline span")
        message.should have_content("This is a problem")
      end
    end

    it "implements error_class" do
      form_for(@reg) do |f|
        f.object.title = nil
        f.object.slug = 'blahblah'
        f.object.save
        error_class(f, :slug).should eq('field-success')
        error_class(f, :title).should eq('field-failure')
      end
    end

    it "implements member_error_class success" do
      form_for(@reg) do |f|
        member_error_class(f.object).should be(nil)

        f.object.title = 'foobar'
        member_error_class(f.object).should eq('member-success')
      end
    end

    it "implements member_error_class failure" do
      form_for(@reg) do |f|
        member_error_class(f.object).should be(nil)

        f.object.title = nil
        f.object.save
        member_error_class(f.object).should eq('member-failure')
      end
    end
  end
end
