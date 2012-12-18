# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :control_assessment do
    pbc_list { |c| c.association(:pbc_list) }
    control { |c| c.association(:control) }
    control_version "MyString"
    internal_tod false
    internal_toe false
    external_tod false
    external_toe false
    notes "MyText"
  end
end
