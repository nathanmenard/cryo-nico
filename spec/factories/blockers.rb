FactoryBot.define do
  factory :blocker do
    user
    franchise
    room
    start_time do
      from = Time.now.to_f
      to = 3.days.from_now.to_f
      Time.at(from + rand * (to - from))
    end
    end_time do
      from = Time.now.to_f
      to = 3.days.from_now.to_f
      Time.at(from + rand * (to - from))
    end
    notes { 'Hello World!' }
  end
end
