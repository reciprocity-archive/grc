require 'spec_helper'

describe ImportHelper do
  it "should parse document reference using markup" do
    parse_document_reference("abc [link a title] x\nabc [link]").should ==
      [
        { :description => 'abc  x', :link => 'link', :title => 'a title' },
        { :description => 'abc ', :link => 'link', :title => 'link' }
    ]
  end
end
