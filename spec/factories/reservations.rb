FactoryBot.define do
  factory :reservation do
    client
    product_price
    start_time do
      from = Time.now.to_f
      to = 3.days.from_now.to_f
      Time.at(from + rand * (to - from))
    end
    email_notification { true }
    to_be_paid_online { false }
  end
end
