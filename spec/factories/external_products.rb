FactoryBot.define do
  factory :external_product do
    franchise
    name { 'Product 1' }
    amount { 20 }
    tax_rate { 5.5 }
  end
end
