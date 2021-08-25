FactoryBot.define do
  factory :user do
    franchise
    sequence(:email) { |i| "sayid.mimouni.#{i}@gmail.com" }
    password { 'azerty' }
    first_name { 'Saïd' }
    last_name { 'Mimouni' }
  end
end
