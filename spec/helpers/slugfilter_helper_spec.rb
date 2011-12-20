require 'spec_helper'

describe SlugfilterHelper do
  before :each do
  end

  def labels(m)
    m.map {|x| x[:label]}
  end

  it "works with distinct slugs" do
    labels(helper.organize_slugs(%w(s1 s2 s3))).should eq(%w(s1 s2 s3))
  end
  it "works with slugs that have more" do
    labels(helper.organize_slugs(%w(s1 s2 s21))).should eq(%w(s1 s2...))
    labels(helper.organize_slugs(%w(s1 s2 s21 s22))).should eq(%w(s1 s2...))
  end
  it "works with a single slug that has more" do
    labels(helper.organize_slugs(%w(s2 s21 s22))).should eq(%w(s2... s21 s22))
  end
  it "works with a single slug that has more and second level has more" do
    labels(helper.organize_slugs(%w(s2 s21 s211 s22))).should eq(%w(s2... s21... s22))
  end
end
