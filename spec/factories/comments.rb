FactoryBot.define do
  factory :comment do
    user
    client
    body { 'Hello World!' }
  end
end
