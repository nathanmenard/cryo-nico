FactoryBot.define do
  factory :product_price do
    product
    session_count { 1 }
    total { 30 }
    professionnal { false }
  end
end
