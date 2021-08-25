namespace :subscription do
  task sync: :environment do
    subscriptions = Subscription.active
    subscriptions.each do |subscription|
      return if subscription.created_at.day != Date.today.day
      (subscription.subscription_plan.session_count).times do |i|
        subscription.client.credits.create!(
          product: subscription.subscription_plan.product,
        )
      end
    end
  end
end
