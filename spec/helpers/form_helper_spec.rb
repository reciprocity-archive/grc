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

  context "wrapped_* helpers" do
    before :each do
      init_haml_helpers
      create_base_objects
    end

    it "wraps textarea" do
      form_for(@reg) do |f|
        message = wrapped_text_area(f, :span4, :title)
        message.should have_selector("div.span4")
        message.should have_selector("div.span4 > textarea")
        message.should have_selector("div.span4 > label")
        message.should have_selector("div.span4 > span.help-inline")
      end
    end

    it "wraps text field" do
      form_for(@reg) do |f|
        message = wrapped_text_field(f, :span4, :title)
        message.should have_selector("div.span4")
        message.should have_selector("div.span4 > input[type='text']")
        message.should have_selector("div.span4 > label")
        message.should have_selector("div.span4 > span.help-inline")
      end
    end

    it "wraps date field" do
      form_for(@reg) do |f|
        f.object.start_date = Date.new(2003, 1, 2).to_time_in_current_zone
        message = wrapped_date_field(f, :span4, :start_date)
        message.should have_selector("div.span4")
        message.should have_selector("div.span4 > input[type='text']")
        message.should have_selector("div.span4 > label")
        message.should have_selector("div.span4 > span.help-inline")
        message.should have_selector("div.span4 > input[value='01/02/2003']")
      end
    end

    it "wraps select" do
      form_for(@reg) do |f|
        message = wrapped_select(f, :span4, :kind, [['A', 'a'], ['B', 'b']])
        message.should have_selector("div.span4")
        message.should have_selector("div.span4 > select")
        message.should have_selector("div.span4 > select > option")
        message.should have_selector("div.span4 > select > option[value='b']")
        message.should have_selector("div.span4 > select > option[value='a']")
        message.should have_selector("div.span4 > label")
        message.should have_selector("div.span4 > span.help-inline")
      end
    end

    it "allows a custom label with :label_name option" do
      form_for(@reg) do |f|
        message = wrapped_text_field(f, :span4, :title, :label_name => 'custom')
        message.should have_selector("div.span4 > label")
        message.should have_content("custom")
      end
    end

    it "doesn't throw an exception if the method doesn't exist" do
      form_for(@reg) do |f|
        message = wrapped_text_field(f, :span4, :blah)
        message.should have_selector("div.span4")
      end
    end
  end

  context "parse_date_param" do
    it "transforms date-formatted string to Time object" do
      params = { :field => '01/02/2003' }.with_indifferent_access
      parse_date_param(params, :field)
      params[:field].should be_a(Time)
      params[:field].should eq(Date.new(2003, 1, 2).to_time_in_current_zone)
    end
  end

  context "parse_option_param" do
    it "transforms option id to Option instance" do
      @opt1 = FactoryGirl.create(:option, :role => 'x', :title => 'X')
      params = { :field_id => @opt1.id }.with_indifferent_access
      parse_option_param(params, 'field')
      params[:field].should be_a(Option)
      params[:field].should eq(@opt1)
    end
  end
end
