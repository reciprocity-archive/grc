require 'spec_helper'

describe SanitizableAttributes do

  class SanitizableAttributesDummyClass
    extend ActiveModel::Callbacks
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include SanitizableAttributes

    attr_accessor :description
    sanitize_attributes :description
  end

  before :each do
    @object = SanitizableAttributesDummyClass.new
    @object.description = "<p>sample</p><script>alert('nasty');</script>"
  end

  it "sanitizes attribute before validation" do
    @object.valid?
    @object.description.should eq("<p>sample</p>")
  end

  context ".sanitize!" do
    it "removes harmful tags" do
      @object.sanitize!
      @object.description.should eq("<p>sample</p>")      
    end
  end

end