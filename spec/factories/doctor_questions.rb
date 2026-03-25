FactoryBot.define do
  factory :doctor_question do
    scan { nil }
    question { "MyText" }
    sort_order { 1 }
  end
end
