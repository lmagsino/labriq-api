FactoryBot.define do
  factory :lab_result do
    scan { nil }
    name { "MyString" }
    value { "MyString" }
    unit { "MyString" }
    status { "MyString" }
    reference_range { "MyString" }
    explanation { "MyText" }
    sort_order { 1 }
  end
end
