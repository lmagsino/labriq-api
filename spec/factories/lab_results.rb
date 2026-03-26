FactoryBot.define do
  factory :lab_result do
    scan
    name { "Glucose" }
    value { "95" }
    unit { "mg/dL" }
    status { "normal" }
    reference_range { "70-100" }
    explanation { "Your glucose level is within normal range." }
    sort_order { 0 }
  end
end
