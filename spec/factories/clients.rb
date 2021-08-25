FactoryBot.define do
  factory :client do
    franchise
    first_name { 'Saïd' }
    last_name { 'Mimouni' }
    sequence(:email) { |n| "client.#{n}@gmail.com" }
    male { true }
  end
end
