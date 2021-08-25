FactoryBot.define do
  factory :campaign do
    franchise
    name { 'My mailing campaign' }
    body { 'Lorem Ipsum..' }
    recipients { ['sayid.mimouni@gmail.com'] }
    draft { true }
    sms { false }
  end
end
