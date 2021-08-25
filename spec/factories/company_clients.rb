FactoryBot.define do
  factory :company_client do
    company
    first_name { 'Djamila' }
    last_name { 'Mimouni' }
    sequence(:email) { |n| "company-client.#{n}@gmail.com" }
  end
end
