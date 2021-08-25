FactoryBot.define do
  factory :subscription do
    subscription_plan
    client
    status { 'active' }
    external_id { Time.now.to_i.to_s }
  end
end
