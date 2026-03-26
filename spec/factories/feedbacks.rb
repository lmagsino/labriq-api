FactoryBot.define do
  factory :feedback do
    scan
    lab_result { nil }
    feedback_type { "general" }
    comment { "The analysis was helpful." }
  end
end
