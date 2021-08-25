FactoryBot.define do
  factory :payment do
    client
    amount { 3000 }
    transaction_id { (1..9).to_a.sample(6).join }
    product_name { 'Cryothérapie' }
    mode { 'online' }


    trait :successful do
      bank_name { 'HSBC' }
    end
  end
end
