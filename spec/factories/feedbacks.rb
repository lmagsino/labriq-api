FactoryBot.define do
  factory :feedback do
    scan { nil }
    lab_result { nil }
    feedback_type { "MyString" }
    comment { "MyText" }
  end
end
