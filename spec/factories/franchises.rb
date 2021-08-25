FactoryBot.define do
  factory :franchise do
    name { "Ville #{SecureRandom.random_number*100}" }
  end
end
