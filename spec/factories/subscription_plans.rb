FactoryBot.define do
  factory :subscription_plan do
    product
    session_count { 4 }
    total { 110 }
  end
end
