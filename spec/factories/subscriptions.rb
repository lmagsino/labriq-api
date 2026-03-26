FactoryBot.define do
  factory :subscription do
    user { nil }
    plan { "MyString" }
    stripe_customer_id { "MyString" }
    stripe_subscription_id { "MyString" }
    status { "MyString" }
    expires_at { "2026-03-25 20:40:13" }
  end
end
