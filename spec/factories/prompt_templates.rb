FactoryBot.define do
  factory :prompt_template do
    name { "lab_analysis" }
    version { 1 }
    content { "You are a lab results interpreter. Respond with JSON." }
    ai_model_name { "claude-sonnet-4-5-20241022" }
    active { true }
  end
end
