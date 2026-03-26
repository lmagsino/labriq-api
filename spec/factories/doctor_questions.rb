FactoryBot.define do
  factory :doctor_question do
    scan
    question { "Should I be concerned about my glucose level?" }
    sort_order { 0 }
  end
end
