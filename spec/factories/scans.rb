FactoryBot.define do
  factory :scan do
    user { nil }
    status { "pending" }
    file_count { 1 }
    urgency { "normal" }
    summary { "Most results look normal." }
    prescription_context { nil }
    raw_ai_response { nil }
    analyzed_at { nil }
  end
end
