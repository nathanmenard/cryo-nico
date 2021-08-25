FactoryBot.define do
  factory :coupon do
    franchises { |x| [x.association(:franchise)] }
    name { 'Code de bienvenue' }
    value { 10 }
    sequence(:code) { |n| "WELCOME#{n}" }
    percentage { true }
  end
end
