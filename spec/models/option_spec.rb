require 'spec_helper'

describe Option do
  
  it "should override appropriate roles" do
    overridden_role = Option::ROLES_OVERRIDE.map{|key, value| key}.first
    Option.human_name(overridden_role).should == Option::ROLES_OVERRIDE[overridden_role].humanize.titleize
  end
  
end