FactoryBot.define do
  factory :business_hour do
    franchise
    day { 'Monday' }
    morning_start_time { '10:00' }
    morning_end_time { '12:00' }
    afternoon_start_time { '14:00' }
    afternoon_end_time { '19:00' }
  end
end
