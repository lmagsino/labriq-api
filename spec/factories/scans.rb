FactoryBot.define do
  factory :scan do
    user { nil }
    status { "MyString" }
    file_count { 1 }
    urgency { "MyString" }
    summary { "MyText" }
    prescription_context { "MyText" }
    raw_ai_response { "" }
    analyzed_at { "2026-03-25 20:39:49" }
  end
end
