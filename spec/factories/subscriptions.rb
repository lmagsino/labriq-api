FactoryBot.define do
  factory :subscription do
    user
    plan { "pro" }
    stripe_customer_id { "cus_test123" }
    stripe_subscription_id { "sub_test123" }
    status { "active" }
    expires_at { 30.days.from_now }
  end
end
