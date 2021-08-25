FactoryBot.define do
  factory :review do
    product
    client
    body { 'Lorem Ipsum..' }
  end
end
