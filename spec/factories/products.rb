FactoryBot.define do
  factory :product do
    room
    sequence(:name) { |n| "Product #{n}" }
    description { "Lorem Ipsum.." }
    duration { 30 }
  end
end
